class DocumentsController < ApplicationController
  before_filter :set_object, :except => [ :index, :new, :create ]
  before_filter :create_object, :only => [ :new, :create ]

  def index
    @documents = Document.paginate :page => params[:page]
  end

  def search
    @documents = Document.search(params[:text]).paginate :page => params[:page]
    render :action => 'index'
  end

  def create
    @document.tag_list.add 'inbox'

    if @document.save
      spawn do
        @document.storage_processing
      end

      # We can't send them to the inbox because it
      # won't quite be ready yet, let them go manually
      redirect_to documents_path
    else
      # TODO change to error
      flash[:notice] = 'Failed to save document'
    end
  end

  def update
    if @document.update_attributes(params['document'])
      # This way reloads don't try to repost
      redirect_to edit_document_path(@document)
    else
      render :action => 'edit'
    end
  end

  def lightbox
    @public_url = AmazonHelper.signed_fetch(params[:key])

    render :layout => false
  end

  private
  def set_object
    @document = Document.find(params[:id]) unless params[:id].blank?
  end

  def create_object
    opts = params[:document] || {}

    @document = Document.new(opts)
  end

end
