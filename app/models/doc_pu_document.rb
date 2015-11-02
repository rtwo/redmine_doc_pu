require 'latex_flags'
require 'latex_doc'

class DocPuDocument < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project
  has_many :doc_pu_wiki_pages, :dependent => :destroy

  validates_presence_of :name, :template, :user_id, :project_id
  validates_uniqueness_of :name

  after_initialize :parse_flags_from_text
  before_save :save_flags_to_text

  include ModuleLatexFlags
  include ModuleLatexDoc


  def build(filename = nil)
    # Set document attributes
    self.latex_template.doc_title = (self.doc_title != "" ? self.doc_title : self.name)
    self.latex_template.doc_author = (self.doc_author != "" ? self.doc_author : self.user.name)
    self.latex_template.doc_date = (self.doc_date != "" ? self.doc_date : self.built_at)
    super(filename)
  end

  # Get wiki pages
  def wiki_pages
    self.doc_pu_wiki_pages.all
  end

  def parse_flags_from_text
    self.flags_from_str(self.doc_flags)
  end

  def save_flags_to_text
    self.doc_flags = self.flags_to_str
    true
  end

  def after_destroy
    # Delete document file, if exist
    File.delete(self.filepath) if File.exist?(self.filepath)
    true
  end

  def filepath
    Rails.root.join("files", self.filename)
  end

  def filename
    "doc_pu_#{self.id}.pdf"
  end
end
