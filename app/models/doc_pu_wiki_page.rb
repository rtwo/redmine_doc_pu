require 'latex_flags'
require 'latex_wiki_page'

class DocPuWikiPage < ActiveRecord::Base
  unloadable

  belongs_to :wiki_page
  belongs_to :doc_pu_document
  validates_presence_of :wiki_page_id, :doc_pu_document_id

  after_initialize :parse_flags_from_text 
  before_save :save_flags_to_text 
  
  include ModuleLatexFlags
  include ModuleLatexWikiPage

  def to_latex
    self.chapter_name = (self.chapter_name != "" ? self.chapter_name : self.wiki_page.title.gsub(/_/,' ') )
    # Get document flags
    if self.use_doc_flags && !self.doc_pu_document.nil?
      ModuleLatexFlags::FLAGS.each do |m, v|
        self.send(m.to_s + "=", self.doc_pu_document.send(m))
      end
    end
    super
  end

  def full_page_name
    self.wiki_page ? "#{self.wiki_page.project.name}:#{self.wiki_page.title}" : nil 
  end

  def parse_flags_from_text 
    self.flags_from_str(self.flags)
    true
  end

  def save_flags_to_text
    self.flags = self.flags_to_str
    true
  end
end
