require 'latex_flags'

module ModuleLatexWikiPage
  include ModuleLatexFlags

  def get_page_text page, version = 0
    # Collect all attached images and get disk filename
    page.attachments.each do |att|
      unless MIME::Types.type_for(att.filename).all? { |s| s.to_s.match(/^image/i).nil? }
        @file_sub[att.filename] = if att.disk_directory.nil?
          att.disk_filename                          
        else
          File.join(att.disk_directory, att.disk_filename)
        end
      end
    end
    
    # Get version of page
    if version == 0
      # Get latest page
      page_txt = String.new(page.content.text)
    else
      ver = page.content.versions.find(:first, :conditions => [ "version = ?", version])
      raise ArgumentError, "Can't find Page version!" if ver.nil?
      page_txt = String.new(ver.text)
    end
  
    # process Include macro
    page_txt.gsub!(/\{\{Include\((.*)\)\}\}/) { |p|
      included_page = Wiki.find_page($1, :project => self.wiki_page.project)
      get_page_text included_page
    }
    page_txt
  end

  def latex_label wiki_page
    "page:#{wiki_page.project.name.gsub(' ','_')}_#{wiki_page.title.gsub(' ', '_')}"
  end

  def to_latex()
    @file_sub = {}
    page_txt = get_page_text self.wiki_page, self.wiki_page_version

    
    # Replace alle image filenames with disk filenames
    @file_sub.each do |fn, dsk_fn|
      page_txt.gsub!(fn, dsk_fn)
    end
    # Check wiki referenzes for redirects
    page_txt.gsub!(/(\s|^)\[\[(.*?)(\|(.*?)|)\]\]/i) do |m|
      ref = $2
      label = $4
      referenced_page = Wiki.find_page($2, :project => self.wiki_page.project)
      if referenced_page
        ref = self.latex_label referenced_page 
        " [[#{ref}|#{label || referenced_page.pretty_title}]]"
      else
        " #{$2}"
      end
    end
    
    # Collect rules
    rules = []
    rules.push(:latex_image_ref) if self.latex_image_ref
    rules.push(:latex_code) if self.latex_code
    rules.push(:latex_page_ref) if self.latex_page_ref
    rules.push(:latex_footnote) if self.latex_footnote
    rules.push(:latex_index_emphasis) if self.latex_index_emphasis
    rules.push(:latex_index_importance) if self.latex_index_importance
    rules.push(:latex_remove_macro) if self.latex_remove_macro
    
    # Convert page to latex
    r = TextileDocLatex.new(page_txt)
    r.draw_table_border_latex = self.latex_table_border
    page_txt = r.to_latex(*rules)
  
    if self.latex_add_chapter
      # Add chapter tag
      page_txt = "\n\\chapter{#{self.chapter_name}} \\label{#{self.latex_label self.wiki_page}}\n" + page_txt
    else
      # Add label to first section, if section exists
      page_txt.sub!(/\\section\{(.+)\}/i) do |m| 
        "\\section{#{$1}}\\label{#{self.latex_label self.wiki_page}}"
      end
    end
    
    return page_txt
  end
end

class LatexWikiPage
  include ModuleLatexWikiPage
  
  attr_accessor :wiki_page
  attr_accessor :wiki_page_version
  attr_accessor :chapter_name
  
  def initialize(wiki_page, wiki_page_version = 0, chapter_name = "Chapter")
    self.wiki_page = wiki_page
    self.wiki_page_version = wiki_page_version
    self.chapter_name = chapter_name
    
    # Set default flag values
    ModuleLatexWikiPage::FLAGS.each do |m, v|
      self.send(m.to_s + "=", v)
    end
  end
end
