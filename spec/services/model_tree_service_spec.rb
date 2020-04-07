# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelTreeService do
  let(:modeling_service) { described_class.new }
  let(:work) do
    create(:public_monograph) do |m|
      m.ordered_members << asset_1
      m.ordered_members << asset_2
      m.ordered_members << asset_3
      m.save!
      # Save assets to force reindexing!!!
      asset_1.save!
      asset_2.save!
      asset_3.save!
      m
    end
  end
  let(:asset_1) { create(:public_file_set) }
  let(:asset_2) { create(:public_file_set) }
  let(:asset_3) { create(:public_file_set) }
  let(:work_noid) { work.id }
  let(:parent_noid) { asset_1.id }
  let(:child_noid) { asset_2.id }
  let(:other_noid) { asset_3.id }

  before { work }

  context 'class methods' do
    describe '#modeling?' do
      subject { described_class.modeling? }

      let(:modeling) { nil }

      before { allow(Settings).to receive(:modeling).and_return(modeling) }

      it { is_expected.to be false }

      context 'modeling' do
        let(:modeling) { double('modeling') }

        it { is_expected.to be true }
      end
    end
  end

  describe '#link' do
    subject(:rvalue) { modeling_service.link(parent_noid, child_noid) }

    it 'creates vertices and edge' do
      expect(subject).to be true
      edge = ModelTreeEdge.find_by(parent_noid: parent_noid, child_noid: child_noid)
      expect(edge.parent_noid).to eq parent_noid
      expect(edge.child_noid).to eq child_noid
      parent_vertex = ModelTreeVertex.find_by(noid: parent_noid)
      expect(parent_vertex.representative).to be false
      child_vertex = ModelTreeVertex.find_by(noid: child_noid)
      expect(child_vertex.representative).to be true
      child_entity = Sighrax.from_noid(child_noid)
      expect(child_entity.representative?).to be true
      expect(child_entity.principal_noid).to eq parent_noid
    end

    it 'does nothing if the link exist' do
      expect(modeling_service.link(parent_noid, child_noid)).to be true
      expect { subject }
        .to change(ModelTreeVertex, :count).by(0)
        .and change(ModelTreeEdge, :count).by(0)
      expect(rvalue).to be true
    end

    it 'does nothing if the child already has a parent' do
      expect(modeling_service.link(other_noid, child_noid)).to be true
      expect { subject }
        .to change(ModelTreeVertex, :count).by(0)
        .and change(ModelTreeEdge, :count).by(0)
      expect(rvalue).to be false
    end
  end

  describe '#unlink_parent' do
    subject(:rvalue) { modeling_service.unlink_parent(child_noid) }

    it 'does nothing if the edge does not exist' do
      expect { subject }
        .to change(ModelTreeVertex, :count).by(0)
        .and change(ModelTreeEdge, :count).by(0)
      expect(rvalue).to be true
    end

    context 'edge exist' do
      before { modeling_service.link(parent_noid, child_noid) }

      it 'does nothing if the node is not a child' do
        expect { modeling_service.unlink_parent(parent_noid) }
          .to change(ModelTreeVertex, :count).by(0)
          .and change(ModelTreeEdge, :count).by(0)
        expect(rvalue).to be true
      end

      it 'destroys vertices and edge' do
        expect { subject }
          .to change(ModelTreeVertex, :count).by(-2)
          .and change(ModelTreeEdge, :count).by(-1)
        expect(rvalue).to be true
        child_entity = Sighrax.from_noid(child_noid)
        expect(child_entity.representative?).to be false
        expect(child_entity.principal_noid).to be nil
      end

      context 'parent has other child' do
        before { modeling_service.link(parent_noid, other_noid) }

        it 'destroys child vertex and edge' do
          expect { subject }
            .to change(ModelTreeVertex, :count).by(-1)
            .and change(ModelTreeEdge, :count).by(-1)
          expect(rvalue).to be true
          expect(ModelTreeVertex.find_by(noid: child_noid)).to be nil
          child_entity = Sighrax.from_noid(child_noid)
          expect(child_entity.representative?).to be false
          expect(child_entity.principal_noid).to be nil
          other_entity = Sighrax.from_noid(other_noid)
          expect(other_entity.representative?).to be true
          expect(other_entity.principal_noid).to eq parent_noid
        end
      end

      context 'child has child' do
        before { modeling_service.link(child_noid, other_noid) }

        it 'destroys parent vertex and edge' do
          expect { subject }
            .to change(ModelTreeVertex, :count).by(-1)
            .and change(ModelTreeEdge, :count).by(-1)
          expect(rvalue).to be true
          expect(ModelTreeVertex.find_by(noid: parent_noid)).to be nil
          child_entity = Sighrax.from_noid(child_noid)
          expect(child_entity.representative?).to be false
          expect(child_entity.principal_noid).to be nil
          other_entity = Sighrax.from_noid(other_noid)
          expect(other_entity.representative?).to be true
          expect(other_entity.principal_noid).to eq child_noid
        end
      end
    end
  end

  describe '#unlink_children' do
    subject(:rvalue) { modeling_service.unlink_children(parent_noid) }

    it 'does nothing if the edge does not exist' do
      expect { subject }
        .to change(ModelTreeVertex, :count).by(0)
        .and change(ModelTreeEdge, :count).by(0)
      expect(rvalue).to be true
    end

    context 'parent has child' do
      before do
        modeling_service.link(parent_noid, child_noid)
        allow(modeling_service).to receive(:unlink_parent).with(child_noid).and_call_original
      end

      it 'calls unlink parent with child' do
        expect { subject }
          .to change(ModelTreeVertex, :count).by(-2)
          .and change(ModelTreeEdge, :count).by(-1)
        expect(rvalue).to be true
        expect(modeling_service).to have_received(:unlink_parent).with(child_noid)
      end

      context 'parent has other child' do
        before do
          modeling_service.link(parent_noid, other_noid)
          allow(modeling_service).to receive(:unlink_parent).with(other_noid).and_call_original
        end

        it 'calls unlink parent with each child' do
          expect { subject }
            .to change(ModelTreeVertex, :count).by(-3)
            .and change(ModelTreeEdge, :count).by(-2)
          expect(rvalue).to be true
          expect(modeling_service).to have_received(:unlink_parent).with(child_noid)
          expect(modeling_service).to have_received(:unlink_parent).with(other_noid)
        end
      end
    end
  end

  context 'select_options' do
    context 'work' do
      describe '#select_parent_options' do
        subject { modeling_service.select_parent_options(work_noid) }

        it { is_expected.to be_empty }
      end

      describe '#select_child_options' do
        subject { modeling_service.select_child_options(work_noid) }

        it { is_expected.to contain_exactly(parent_noid, child_noid, other_noid) }

        context 'has child' do
          before {  modeling_service.link(work_noid, child_noid) }

          it { is_expected.to contain_exactly(parent_noid, other_noid) }
        end
      end
    end

    context 'asset' do
      describe '#select_parent_options' do
        subject { modeling_service.select_parent_options(child_noid) }

        it { is_expected.to contain_exactly(work_noid, parent_noid, other_noid) }

        context 'has parent' do
          before { modeling_service.link(parent_noid, child_noid) }

          it { is_expected.to be_empty }
        end
      end

      describe '#select_child_options' do
        subject { modeling_service.select_child_options(parent_noid) }

        it { is_expected.to contain_exactly(child_noid, other_noid) }

        context 'has child' do
          before { modeling_service.link(parent_noid, child_noid) }

          it { is_expected.to contain_exactly(other_noid) }

          context 'other has parent' do
            before { modeling_service.link(work_noid, other_noid) }

            it { is_expected.to be_empty }
          end
        end
      end
    end
  end
end
