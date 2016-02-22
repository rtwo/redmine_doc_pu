class DocPuWikiController < ApplicationController
    unloadable
    layout "base"
    menu_item :doc_pu_menu
    before_filter :find_project, :find_doc_pu_document, :except => [:list_wiki_pages]

    # Show all wiki pages
    def index
        @doc_pu_wikis = @doc_pu.doc_pu_wiki_pages
    end

    # ajax call for autocomplete of wiki page
    def list_wiki_pages
      results = WikiPage.joins(wiki: :project)
                .where("CONCAT_WS(':', `projects`.`name`, `wiki_pages`.`title`) LIKE ? ", "%#{params[:term]}%")
                .select('projects.name, wiki_pages.title')
                .limit(10)

      render :json => results.map { |x| "#{x.name}:#{x.title}" }
    end

    # Create new wiki page
    def new
        @doc_pu_wiki = DocPuWikiPage.new()
        @doc_pu_wiki.use_doc_flags = true
        if request.post?
            # Save object
            reorder_pages(@doc_pu.doc_pu_wiki_pages.all)
            @doc_pu_wiki = @doc_pu.doc_pu_wiki_pages.create(parse_form params[:doc_pu_wiki])
            @doc_pu_wiki.wiki_page_order = get_new_page_order()
            @doc_pu_wiki.wiki_page_version = 0
            if @doc_pu_wiki.save
                flash[:notice] = t(:flash_page_saved)
                redirect_to :controller => :doc_pu, :action => :edit, :project_id => @project, :id => @doc_pu
                return
            end
        end
    end

    # Edit wiki page
    def edit
      @doc_pu_wiki = DocPuWikiPage.find(params[:id])
      if request.put?
        # Update object
        @doc_pu_wiki.attributes = parse_form(params[:doc_pu_wiki])
        if @doc_pu_wiki.save
          flash[:notice] = t(:flash_page_updated)
          redirect_to :controller => :doc_pu, :action => :edit, :project_id => @project, :id => @doc_pu
          return
        end
      end
    end

    # Edit page order
    def edit_order
        ordered_wikis = @doc_pu.doc_pu_wiki_pages.all.to_a
        wiki = DocPuWikiPage.find(params[:id])
        move_to = params[:doc_pu_wiki][:move_to]
        ordered_wikis.delete(wiki)

        case move_to
            when "highest" then ordered_wikis.insert(0, wiki)
            when "lowest" then ordered_wikis.insert(-1, wiki)
            when "higher" then ordered_wikis.insert(wiki.wiki_page_order - 1, wiki)
            when "lower" then ordered_wikis.insert(wiki.wiki_page_order + 1, wiki)
        end
        reorder_pages(ordered_wikis)
        redirect_to :controller => :doc_pu, :action => :edit, :project_id => @project, :id => @doc_pu
    end

    # Delete wiki page
    def delete
        @doc_pu_wiki = DocPuWikiPage.find(params[:id])
        @doc_pu_wiki.destroy
        flash[:notice] = t(:flash_page_deleted)
        redirect_to :controller => :doc_pu, :action => :edit, :project_id => @project, :id => @doc_pu
    end


    def find_doc_pu_document
        @doc_pu = DocPuDocument.find(params[:doc_pu_id])
    end

    def find_project
        @project = Project.find(params[:project_id])
    end

    def reorder_pages(ordered_pages)
        idx = 0
        ordered_pages.each do |page|
            unless page.nil?
                page.wiki_page_order = idx
                page.save
                idx += 1
            end
        end
    end

    def get_new_page_order
        page = @doc_pu.doc_pu_wiki_pages.all.last.wiki_page_order
        page = 0 if page.nil?
        return page + 1
    end

    def parse_form(param)
        # Convert checkbox value to boolean
        ModuleLatexFlags::FLAGS.each do |m, v|
            param[m.to_s] = (param[m.to_s] == "1")
        end
        # Lookup wiki page
        full_page_name = param.delete(:full_page_name)
        page = Wiki.find_page(full_page_name)
        param[:wiki_page_id] = page.nil? ? nil : page.id
        return param
    end
end
