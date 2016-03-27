class Site::FeedbackController < Site::SiteController
  Haml::Template.options[:format] = :xhtml
  def create
    @email = Email.new(feedback_params)
    FeedbackMailer.feedback_form(@email).deliver_now
    redirect_to root_path
  end
  protected
  def feedback_params
    params.require(:email).permit(:name, :email, :subject, :message)
  end
end
