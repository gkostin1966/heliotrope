# frozen_string_literal: true

Hyrax::Actors::FileSetActor.class_eval do
  prepend(HeliotropeFileSetActorOverrides = Module.new do
    # Spawns asynchronous IngestJob unless ingesting from URL
    # Called from FileSetsController, AttachFilesToWorkJob, IngestLocalFileJob, ImportUrlJob
    # @param [Hyrax::UploadedFile, File, ActionDigest::HTTP::UploadedFile] file the file uploaded by the user
    # @param [Symbol, #to_s] relation
    # @return [IngestJob, FalseClass] false on failure, otherwise the queued job
    def create_content(file, relation = :original_file, from_url: false)
      # If the file set doesn't have a title or label assigned, set a default.
      file_set.label = label_for(file)
      file_set.title = [file_set.label] if file_set.title.blank?
      return false unless file_set.save # Need to save to get an id
      if from_url
        # If ingesting from URL, don't spawn an IngestJob; instead
        # reach into the FileActor and run the ingest with the file instance in
        # hand. Do this because we don't have the underlying UploadedFile instance
        file_actor = build_file_actor(relation)
        file_actor.ingest_file(wrapper!(file: file, relation: relation))
        # Copy visibility and permissions from parent (work) to
        # FileSets even if they come in from BrowseEverything
        VisibilityCopyJob.perform_later(file_set.parent)
        InheritPermissionsJob.perform_later(file_set.parent)
      else
        IngestJob.perform_later(wrapper!(file: file, relation: relation))
      end
    end
  end)
end

