# frozen_string_literal: true

require 'rails_helper'

require 'database_cleaner/active_record'

RSpec.describe 'Ability Can', type: :integration do
  before(:context) do
    @press = create(:press)

    @anonymous = Anonymous.new({})
    @user = create(:user)
    @editor = create(:press_editor)
    @admin = create(:press_admin)
    @press_editor = create(:press_editor, press: @press)
    @press_admin = create(:press_admin, press: @press)
    @platform_admin = create(:platform_admin)

    @private_jpg = create(:file_set, content: File.open(File.join(fixture_path, 'moby-dick.jpg')))
    @private_epub = create(:file_set, content: File.open(File.join(fixture_path, 'moby-dick.epub')))
    @private_pdf = create(:file_set, content: File.open(File.join(fixture_path, 'moby-dick.pdf')))
    @private_monograph =  create(:monograph, press: @press.subdomain, representative_id: @private_jpg.id) do |m|
      m.ordered_members << @private_jpg
      m.ordered_members << @private_epub
      m.ordered_members << @private_pdf
      m.save!
      @private_jpg.save!
      @private_epub.save!
      @private_pdf.save!
      m
    end
    @sighrax_private_monograph = Sighrax.from_noid(@private_monograph.id)
    @sighrax_private_file_set = Sighrax.from_noid(@private_jpg.id)

    @public_jpg = create(:public_file_set, content: File.open(File.join(fixture_path, 'moby-dick.jpg')))
    @public_epub = create(:public_file_set, content: File.open(File.join(fixture_path, 'moby-dick.epub')))
    @public_pdf = create(:public_file_set, content: File.open(File.join(fixture_path, 'moby-dick.pdf')))
    @public_monograph = create(:public_monograph, press: @press.subdomain, representative_id: @public_jpg.id) do |m|
      m.ordered_members << @public_jpg
      m.ordered_members << @public_epub
      m.ordered_members << @public_pdf
      m.save!
      @public_jpg.save!
      @public_epub.save!
      @public_pdf.save!
      m
    end
    @sighrax_public_monograph = Sighrax.from_noid(@public_monograph.id)
    @sighrax_public_file_set = Sighrax.from_noid(@public_jpg.id)
  end

  before(:example) do
    # NOTE: Not necessary but might be necessary in the future so this is just a reminder for the future
    # @press.reload
  end

  after(:context) do
    ActiveFedora::Cleaner.clean!
    DatabaseCleaner.clean_with(:truncation)
  end

  context 'role validation' do
    context 'Sighrax' do
      it('platform_admin') { expect(Sighrax.platform_admin?(@platform_admin)).to be true }
      it('press_admin') { expect(Sighrax.press_admin?(@press_admin, @press)).to be true }
      it('press_editor') { expect(Sighrax.press_editor?(@press_editor, @press)).to be true }
      it('admin') { expect(Sighrax.press_admin?(@admin, @press)).to be false }
      it('editor') { expect(Sighrax.press_editor?(@editor, @press)).to be false }
    end

    context 'ability' do
      context 'platform_admin' do
        it('platform_admin?') { expect(Ability.new(@platform_admin).admin?).to be true }
        it('press_admin?') { expect(Ability.new(@platform_admin).press_admin?).to be true }
        it('admin_for?') { expect(Ability.new(@platform_admin).admin_for?(@press)).to be true }
        it('press_editor?') { expect(Ability.new(@platform_admin).press_editor?).to be true }
        it('editor_for?') { expect(Ability.new(@platform_admin).editor_for?(@press)).to be true }
      end

      context 'press_admin' do
        it('platform_admin?') { expect(Ability.new(@press_admin).admin?).to be false }
        it('press_admin?') { expect(Ability.new(@press_admin).press_admin?).to be true }
        it('admin_for?') { expect(Ability.new(@press_admin).admin_for?(@press)).to be true }
        it('press_editor?') { expect(Ability.new(@press_admin).press_editor?).to be false }
        it('editor_for?') { expect(Ability.new(@press_admin).editor_for?(@press)).to be false }
      end

      context 'press_editor' do
        it('platform_admin?') { expect(Ability.new(@press_editor).admin?).to be false }
        it('press_admin?') { expect(Ability.new(@press_editor).press_admin?).to be false }
        it('admin_for?') { expect(Ability.new(@press_editor).admin_for?(@press)).to be false }
        it('press_editor?') { expect(Ability.new(@press_editor).press_editor?).to be true }
        it('editor_for?') { expect(Ability.new(@press_editor).editor_for?(@press)).to be true }
      end

      context 'admin' do
        it('platform_admin?') { expect(Ability.new(@admin).admin?).to be false }
        it('press_admin?') { expect(Ability.new(@admin).press_admin?).to be true }
        it('admin_for?') { expect(Ability.new(@admin).admin_for?(@press)).to be false }
        it('press_editor?') { expect(Ability.new(@admin).press_editor?).to be false }
        it('editor_for?') { expect(Ability.new(@admin).editor_for?(@press)).to be false }
      end

      context 'editor' do
        it('platform_admin?') { expect(Ability.new(@editor).admin?).to be false }
        it('press_admin?') { expect(Ability.new(@editor).press_admin?).to be false }
        it('admin_for?') { expect(Ability.new(@editor).admin_for?(@press)).to be false }
        it('press_editor?') { expect(Ability.new(@editor).press_editor?).to be true }
        it('editor_for?') { expect(Ability.new(@editor).editor_for?(@press)).to be false }
      end
    end
  end

  context 'anonymous' do
    context 'private' do
      context 'monograph' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@anonymous, action, @sighrax_private_monograph)).to be false }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@anonymous, action, @sighrax_private_file_set)).to be false }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@anonymous, action, @sighrax_public_monograph)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@anonymous, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@anonymous, action, @sighrax_public_file_set)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@anonymous, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end

  context 'user' do
    context 'private' do
      context 'monograph' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@user, action, @sighrax_private_monograph)).to be false }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@user, action, @sighrax_private_file_set)).to be false }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@user, action, @sighrax_public_monograph)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@user, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@user, action, @sighrax_public_file_set)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@user, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end

  context 'editor' do
    context 'private' do
      context 'monograph' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@editor, action, @sighrax_private_monograph)).to be false }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@editor, action, @sighrax_private_file_set)).to be false }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@editor, action, @sighrax_public_monograph)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@editor, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@editor, action, @sighrax_public_file_set)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@editor, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end

  context 'admin' do
    context 'private' do
      context 'monograph' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@admin, action, @sighrax_private_monograph)).to be false }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@admin, action, @sighrax_private_file_set)).to be false }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@admin, action, @sighrax_public_monograph)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@admin, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'cannot' do
          %i[create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@admin, action, @sighrax_public_file_set)).to be false }
          end
        end
        context 'can' do
          %i[read].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@admin, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end

  context 'press_editor' do
    context 'private' do
      context 'monograph' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_editor, action, @sighrax_private_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_editor, action, @sighrax_private_file_set)).to be true }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_editor, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_editor, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end

  context 'press_admin' do
    context 'private' do
      context 'monograph' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_admin, action, @sighrax_private_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_admin, action, @sighrax_private_file_set)).to be true }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_admin, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@press_admin, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end

  context 'platform_admin' do
    context 'private' do
      context 'monograph' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@platform_admin, action, @sighrax_private_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@platform_admin, action, @sighrax_private_file_set)).to be true }
          end
        end
      end
    end
    context 'public' do
      context 'monograph' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@platform_admin, action, @sighrax_public_monograph)).to be true }
          end
        end
      end
      context 'file_set' do
        context 'can' do
          %i[read create update destroy].each do |action|
            it("#{action}") { expect(Sighrax.ability_can?(@platform_admin, action, @sighrax_public_file_set)).to be true }
          end
        end
      end
    end
  end
end
