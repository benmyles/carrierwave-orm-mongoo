# encoding: utf-8

require 'mongoo'
require 'carrierwave/validations/active_model'

module CarrierWave
  module Mongoo

    include CarrierWave::Mount

    ##
    # See +CarrierWave::Mount#mount_uploader+ for documentation
    #
    def mount_uploader(column, uploader=nil, options={}, &block)
      super

      alias_method :read_uploader, :get
      alias_method :write_uploader, :set
      public :read_uploader
      public :write_uploader

      include CarrierWave::Validations::ActiveModel

      validates_integrity_of column if uploader_option(column.to_sym, :validate_integrity)
      validates_processing_of column if uploader_option(column.to_sym, :validate_processing)

      after_insert :"store_#{column}!"
      after_update :"store_#{column}!"

      before_insert :"write_#{column}_identifier"
      before_update :"write_#{column}_identifier"

      after_remove  :"remove_#{column}!"

      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}=(new_file)
          column = _mounter(:#{column})
          super
        end
      RUBY

    end

  end # Mongoo
end # CarrierWave

Mongoo::Base.extend CarrierWave::Mongoo