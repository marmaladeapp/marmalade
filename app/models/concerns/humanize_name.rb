module HumanizeName
  extend ActiveSupport::Concern

  private

  class_methods do
    def human_name
      model_name.human
    end
  end
end
