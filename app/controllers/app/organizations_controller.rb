class App::OrganizationsController < App::AppController

  def new
    authorize! :new, Business, :message => ""
    authorize! :new, Group, :message => ""
  end

end
