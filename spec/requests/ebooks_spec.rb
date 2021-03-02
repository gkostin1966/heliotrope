# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Download Ebooks", type: :request do
  describe 'ebook download' do
    subject { get download_ebook_path(ebook.id) }

    let(:press) { create(:press) }
    let(:monograph) { create(:public_monograph, press: press.subdomain) }
    let(:ebook) { create(:public_file_set) }
    let(:ebook_fr) { create(:featured_representative, work_id: monograph.id, file_set_id: ebook.id, kind: kind) }
    let(:policy) { instance_double(EntityPolicy, download?: download) }
    let(:download) { false }
    let(:press_policy) { instance_double(PressPolicy, watermark_download?: watermark_download) }
    let(:watermark_download) { false }
    let(:counter_service) { double("counter_service") }

    before do
      monograph.ordered_members = [ebook]
      monograph.save
      ebook.save
      ebook_fr
      allow(EntityPolicy).to receive(:new).and_return(policy)
      allow(PressPolicy).to receive(:new).and_return(press_policy)
      allow(CounterService).to receive(:from).and_return(counter_service)
      allow(counter_service).to receive(:count).with(request: 1)
    end

    context 'when epub' do
      let(:kind) { 'epub' }

      it do
        expect { subject }.not_to raise_error
        expect(response).to have_http_status(:unauthorized)
        expect(response).to render_template('hyrax/base/unauthorized')
        expect(CounterService).not_to have_received(:from)
        expect(counter_service).not_to have_received(:count)
      end

      context 'when download' do
        let(:download) { true }

        it do
          expect { subject }.not_to raise_error
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(hyrax.download_path(ebook.id))
          expect(CounterService).not_to have_received(:from)
          expect(counter_service).not_to have_received(:count)
        end

        context 'when watermark download' do
          let(:watermark_download) { true }

          it do
            expect { subject }.not_to raise_error
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(hyrax.download_path(ebook.id))
            expect(CounterService).not_to have_received(:from)
            expect(counter_service).not_to have_received(:count)
          end
        end
      end
    end

    context 'when pdf' do
      let(:kind) { 'pdf_ebook' }

      it do
        expect { subject }.not_to raise_error
        expect(response).to have_http_status(:unauthorized)
        expect(response).to render_template('hyrax/base/unauthorized')
        expect(CounterService).not_to have_received(:from)
        expect(counter_service).not_to have_received(:count)
      end

      context 'when download' do
        let(:download) { true }

        it do
          expect { subject }.not_to raise_error
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(hyrax.download_path(ebook.id))
          expect(CounterService).not_to have_received(:from)
          expect(counter_service).not_to have_received(:count)
        end

        context 'when watermark download' do
          let(:watermark_download) { true }
          let(:ebook) { create(:public_file_set, content: File.open(File.join(fixture_path, 'clippath.pdf'))) }
          let(:pdf_ebook) { Sighrax.from_noid(ebook.id) }

          it 'without author(s) no error raised' do
            expect { subject }.not_to raise_error
            expect(response).to have_http_status(:ok)
            expect(response.body).not_to be_empty
            expect(CounterService).to have_received(:from)
            expect(counter_service).to have_received(:count)
            expect(response.header['Content-Type']).to eq(pdf_ebook.media_type)
            expect(response.header['Content-Disposition']).to eq("attachment; filename=\"#{pdf_ebook.file_name}\"")

            # watermarking will change the file content and PDF 'producer' metadata
            expect(response.body).not_to eq File.read(Rails.root.join(fixture_path, pdf_ebook.file_name))
            expect(response.body).to include('Producer (Ruby CombinePDF')
          end
        end
      end
    end
  end
end
