module ActiveAdmin
  module Globalize
    module FormBuilderExtension
      extend ActiveSupport::Concern

      def translated_inputs(name = "Translations", options = {}, &block)
        options.symbolize_keys!
        available_locales = options.fetch(:available_locales, I18n.available_locales)
        switch_locale = options.fetch(:switch_locale, false)
        default_locale = options.fetch(:default_locale, I18n.default_locale)
        template.content_tag(:div, class: "activeadmin-translations") do
          template.content_tag(:ul, class: "available-locales") do
            available_locales.map do |locale|
              default = 'default' if locale == default_locale
              template.content_tag(:li) do
                I18n.with_locale(switch_locale ? locale : I18n.locale) do
                  template.content_tag(:a, I18n.t(:"active_admin.globalize.language.#{locale}"), href:".locale-#{locale}", :class => default)
                end
              end
            end.join.html_safe
          end <<
          available_locales.map do |locale|
            translation = object.translations.find { |t| t.locale.to_s == locale.to_s }
            translation ||= object.translations.build(locale: locale)
            fields = proc do |form|
              form.input(:locale, as: :hidden)
              form.input(:id, as: :hidden)
              I18n.with_locale(switch_locale ? locale : I18n.locale) do
                block.call(form)
              end
            end
            inputs_for_nested_attributes(
              for: [:translations, translation ],
              class: "inputs locale locale-#{translation.locale}",
              # permit_params :translation_attributes => [:name, :description] does
              # not permit "translation_attributes" => {"en" => {:name =>, "", :description => ""}, "de" => ...}
              # While the keys can be arbitrary, they must be integers
              for_options: {child_index: translation.locale.to_s.bytes.select{|b| b != 45}.map{|b| b - 27}.join()},
              &fields
            )
          end.join.html_safe
        end
      end

      module ClassMethods
      end
    end
  end
end
