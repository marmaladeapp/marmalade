class App::DashboardController < App::AppController
  def index
    @abstracts = Abstract.where(
      '(context_type = ? AND context_id = ?) OR 
      (context_type = ? AND context_id IN (?)) OR 
      (context_type = ? AND context_id IN (?)) OR 
      (context_type = ? AND context_id IN (?))', 
      'User', current_user.id, 
      'Business', current_user.businesses.ids, 
      'Household', current_user.households.ids, 
      'Group', current_user.groups.ids
    ).page(params[:page]) #.per(2)
  end
end
