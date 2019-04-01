# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Identifiers", type: :request do
  let(:current_user) { User.guest(user_key: 'wolverine@umich.edu') }
  let(:target) { create(:identifier, uuid: uuid) }
  let(:uuid) { create(:uuid) }

  before { allow(Mighrax).to receive(:uuid_generator_packed).and_return(random_uuid_packed) }

  describe '#index' do
    subject { get "/identifiers" }

    it do
      expect { subject }.not_to raise_error
      expect(response).to redirect_to('/presses?locale=en')
      expect(response).to have_http_status(:found)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.not_to raise_error
        expect(response).to redirect_to('/presses?locale=en')
        expect(response).to have_http_status(:found)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.not_to raise_error
          expect(response).to redirect_to('/presses?locale=en')
          expect(response).to have_http_status(:found)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it do
            expect { subject }.not_to raise_error
            expect(response).to render_template(:index)
            expect(response).to have_http_status(:ok)
          end

          context 'filtering' do
            subject { get "/identifiers?name_like=#{target.name}" }

            it do
              expect { subject }.not_to raise_error
              expect(response).to render_template(:index)
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end

  describe '#show' do
    subject { get "/identifiers/#{target.id}" }

    it do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.to raise_error(ActionController::RoutingError)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.to raise_error(ActionController::RoutingError)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it do
            expect { subject }.not_to raise_error
            expect(response).to render_template(:show)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe '#new' do
    subject { get "/identifiers/new" }

    it do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.to raise_error(ActionController::RoutingError)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.to raise_error(ActionController::RoutingError)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it do
            expect { subject }.not_to raise_error
            expect(response).to render_template(:new)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe '#edit' do
    subject { get "/identifiers/#{target.id}/edit" }

    it do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.to raise_error(ActionController::RoutingError)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.to raise_error(ActionController::RoutingError)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it do
            expect { subject }.not_to raise_error
            expect(response).to render_template(:edit)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe '#create' do
    subject { post "/identifiers", params: { mighrax_identifier: identifier_params } }

    let(:identifier_params) { { name: 'name' } }

    it do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.to raise_error(ActionController::RoutingError)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.to raise_error(ActionController::RoutingError)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it do
            expect { subject }.not_to raise_error
            expect(response).to redirect_to(identifier_path(Mighrax::Identifier.find_by(identifier_params)))
            expect(response).to have_http_status(:found)
          end

          context 'invalid identifier params' do
            let(:identifier_params) { { name: '' } }

            it do
              expect { subject }.not_to raise_error
              expect(response).to render_template(:new)
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end

  describe '#update' do
    subject { put "/identifiers/#{target.id}", params: { mighrax_identifier: identifier_params } }

    let(:identifier_params) { { name: 'new_name' } }

    it do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.to raise_error(ActionController::RoutingError)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.to raise_error(ActionController::RoutingError)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it do
            expect { subject }.not_to raise_error
            expect(response).to redirect_to(identifier_path(Mighrax::Identifier.find(target.id)))
            expect(response).to have_http_status(:found)
          end

          context 'invalid identifier params' do
            let(:identifier_params) { { name: '' } }

            it do
              expect { subject }.not_to raise_error
              expect(response).to render_template(:edit)
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end

  describe '#destroy' do
    subject { delete "/identifiers/#{target.id}" }

    it do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end

    context 'authenticated' do
      before { sign_in(current_user) }

      it do
        expect { subject }.to raise_error(ActionController::RoutingError)
      end

      context 'authorized' do
        before { allow_any_instance_of(ApplicationController).to receive(:authorize!) }

        it do
          expect { subject }.to raise_error(ActionController::RoutingError)
        end

        context 'platform administrator' do
          let(:current_user) { create(:platform_admin) }

          it 'without alias' do
            expect { subject }.not_to raise_error
            expect(response).to redirect_to(identifiers_path)
            expect(response).to have_http_status(:found)
            expect { Mighrax::Identifier.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound)
            expect { Mighrax::Uuid.find(target.uuid.id) }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it 'with alias' do
            twin = create(:identifier, uuid: target.uuid)
            expect(target.uuid).to eq(twin.uuid)
            expect { subject }.not_to raise_error
            expect(response).to redirect_to(identifiers_path)
            expect(response).to have_http_status(:found)
            expect { Mighrax::Identifier.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound)
            expect { Mighrax::Uuid.find(target.uuid.id) }.not_to raise_error
            expect { Mighrax::Identifier.find(twin.id) }.not_to raise_error
            expect { Mighrax::Uuid.find(twin.uuid.id) }.not_to raise_error
          end
        end
      end
    end
  end
end
