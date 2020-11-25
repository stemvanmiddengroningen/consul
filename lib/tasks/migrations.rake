namespace :migrations do
  desc "Add name to existing budget phases"
  task add_name_to_existing_budget_phases: :environment do
    Budget::Phase.find_each do |phase|
      unless phase.name.present?
        if phase.translations.present?
          phase.translations.each do |translation|
            unless translation.name.present?
              if I18n.available_locales.include? translation.locale
                locale = translation.locale
              else
                locale = I18n.default_locale
              end
              i18n_name = I18n.t("budgets.phase.#{translation.globalized_model.kind}", locale: locale)
              translation.update!(name: i18n_name)
            end
          end
        else
          phase.translations.create!(name: I18n.t("budgets.phase.#{phase.kind}"), locale: I18n.default_locale)
        end
      end
    end
  end

  desc "Copies the Budget::Phase summary into description"
  task budget_phases_summary_to_description: :environment do
    Budget::Phase::Translation.find_each do |phase|
      if phase.summary.present?
        phase.description << "<br>"
        phase.description << phase.summary
        phase.update!(summary: nil) if phase.save
      end
    end
  end
end
