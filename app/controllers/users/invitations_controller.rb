class Users::InvitationsController < Devise::InvitationsController
  before_filter :configure_invite_params, only: [:create]
  before_filter :configure_accept_invitation_params, only: [:update]

  # GET /resource/invitation/new
  # def new
  #   super
  # end

  # POST /resource/invitation
  def create
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if resource.username.blank?
        resource.username = "u_" + Array.new(8){ [*'0'..'9',*'A'..'Z',*'a'..'z'].sample }.join
        resource.save
      end
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      respond_with resource, :location => after_invite_path_for(current_inviter)
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/invitation
  # def update
  #   super
  # end

  # DELETE /resource/invitation/remove?invitation_token=abcdef
  # def destroy
  #   super
  # end

  protected

  # You can put the params you want to permit in the empty array.
  def configure_invite_params
    devise_parameter_sanitizer.for(:invite) << [:email]
  end

  # You can put the params you want to permit in the empty array.
  def configure_accept_invitation_params
    devise_parameter_sanitizer.for(:accept_invitation) << [:email, :username, :profile_attributes => [:first_name, :last_name, :bio], :organizations_attributes => [:name]]
  end

end
