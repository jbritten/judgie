class BetaInvitationsController < ApplicationController
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }

  # POST /beta_invitations
  def create
    @beta_invitation = BetaInvitation.new(params[:beta_invitation])

    respond_to do |format|
      if @beta_invitation.save
        flash[:notice] = "Invite sent"
        format.html { redirect_to signup_path }
      else
        flash[:notice] = "Invite problem"
        format.html { render :action => "new" }
      end
    end
  end
end
