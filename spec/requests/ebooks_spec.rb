# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Ebooks", type: :request do
  describe "GET /ebooks/:id/download" do
    subject { get download_ebook_path(noid) }

    let(:actor) { instance_double(Anonymous, 'actor') }
    let(:noid) { 'validnoid' }
    let(:ebook) { instance_double(Sighrax::Ebook, 'ebook', noid: noid, data: {}, valid?: true, title: 'title') }
    let(:policy) { instance_double(EbookPolicy, 'policy', download?: download, watermark?: watermark) }
    let(:download) { false }
    let(:watermark) { false }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_actor).and_return actor
      allow(Sighrax).to receive(:from_noid).with(noid).and_return ebook
      allow(EbookPolicy).to receive(:new).with(actor, ebook).and_return policy
    end

    it do
      expect { subject }.not_to raise_error
      expect(response).to have_http_status(:unauthorized)
      expect(response).to render_template('hyrax/base/unauthorized')
    end

    context 'download?' do
      let(:download) { true }

      it do
        expect { subject }.not_to raise_error
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(hyrax.download_path(noid))
      end

      context 'watermark?' do
        let(:watermark) { true }
        let(:ebook) do
          instance_double(
            Sighrax::Ebook,
            'ebook',
            noid: noid,
            data: {},
            valid?: true,
            parent: parent,
            title: 'title',
            resource_token: 'resource_token',
            media_type: 'application/pdf',
            file_name: 'clippath.pdf'
          )
        end
        let(:parent) { instance_double(Sighrax::Ebook, title: 'title') }
        let(:ebook_presenter) { double("ebook_presenter") }
        let(:counter_service) { double("counter_service") }

        before do
          allow(ebook).to receive(:content).and_return(File.read(Rails.root.join(fixture_path, ebook.file_name)))
          allow(Sighrax).to receive(:hyrax_presenter).with(ebook).and_return(ebook_presenter)
          allow(CounterService).to receive(:from).and_return(counter_service)
          allow(counter_service).to receive(:count).with(request: 1).and_return(true)
        end

        context 'presenter returns an authors value' do
          let(:presenter) do
            instance_double(Hyrax::MonographPresenter, authors?: true,
                                                       authors: 'creator blah',
                                                       creator: ['Creator, A.', 'Destroyer, Z.'],
                                                       title: 'title',
                                                       date_created: ['created'],
                                                       based_near_label: ['Somewhere'],
                                                       citable_link: 'www.example.com/something',
                                                       publisher: ['publisher'])
          end

          it 'uses it in the watermark' do
            allow(Sighrax).to receive(:hyrax_presenter).with(parent).and_return(presenter)
            expect { subject }.not_to raise_error
            expect(response).to have_http_status(:ok)
            expect(response.body).not_to be_empty
            # watermarking will change the file content and PDF 'producer' metadata
            expect(response.body).not_to eq File.read(Rails.root.join(fixture_path, ebook.file_name))
            expect(response.body).to include('Producer (Ruby CombinePDF')
            expect(response.header['Content-Type']).to eq(ebook.media_type)
            expect(response.header['Content-Disposition']).to eq("attachment; filename=\"#{ebook.file_name}\"")
            expect(counter_service).to have_received(:count).with(request: 1)
          end
        end

        context 'presenter does not return an authors value' do
          let(:presenter) { instance_double(Hyrax::MonographPresenter, authors?: false,
                                                                       creator: [],
                                                                       title: 'title',
                                                                       date_created: ['created'],
                                                                       based_near_label: ['Somewhere'],
                                                                       citable_link: 'www.example.com/something',
                                                                       publisher: ['publisher']) }

          it "doesn't raise an error" do
            allow(Sighrax).to receive(:hyrax_presenter).with(parent).and_return(presenter)
            expect { subject }.not_to raise_error
            expect(response).to have_http_status(:ok)
            expect(response.body).not_to be_empty
            expect(response.body).not_to eq File.read(Rails.root.join(fixture_path, ebook.file_name))
            expect(response.header['Content-Type']).to eq(ebook.media_type)
            expect(response.header['Content-Disposition']).to eq("attachment; filename=\"#{ebook.file_name}\"")
            expect(counter_service).to have_received(:count).with(request: 1)
          end
        end
      end
    end
  end
end
