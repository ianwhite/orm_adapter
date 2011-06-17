class Hash
  def only(*whitelist)
    {}.tap do |h|
      (keys & whitelist).each { |k| h[k] = self[k] }
    end
  end
end

class UsersController < ActionController::Base
  respond_to :xml

  def index
    respond_with(@users = User.where(params.only('name', 'rating')).order(params[:order]))
  end
  
  def create
    params[:user].delete('__content__')
    params[:user][:notes].map! {|n| Note.find(n[:id]) } rescue nil
    @user = User.create(params[:user])
    respond_with(@user)
  end
  
  def show
    respond_with(@user = User.find(params[:id]))
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    head :ok
  end
end

class NotesController < ActionController::Base
  respond_to :xml
  
  def index
    respond_with(@notes = Note.where(params.only('owner_id')).order(params[:order]))
  end
  
  def show
    respond_with Note.find(params[:id])
  end
  
  def create
    params[:note].delete('__content__')
    params[:note][:owner] = User.find_by_id(params[:note][:owner_id] || params[:note][:owner][:id]) rescue nil
    @note = Note.create(params[:note])
    respond_with(@note)
  end
  
  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    head :ok
  end
end
