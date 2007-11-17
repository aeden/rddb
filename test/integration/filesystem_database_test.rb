require File.dirname(__FILE__) + '/test_helper'

class FilesystemDatabaseTest < Test::Unit::TestCase
  def test_persistent_views
    database = Rddb::Database.new(
      :document_store => document_store,
      :view_store => view_store
    )
    database.create_view('test', :materialization_store => materialization_store) do |document, args|
      document.name
    end
    
    database << {:name => 'Bob'}
    database << {:name => 'Jim'}
    
    database2 = Rddb::Database.new(
      :document_store => document_store,
      :view_store => view_store
    )
    assert_equal [], database2.query('test')
  end
  
  protected
  def document_store(options={})
    Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      {
        :partition_strategy => Proc.new { |document| document.name[0..0] },
        :basedir => File.dirname(__FILE__) + '/../tmp/integration/documents'
      }.merge(options)
    )
  end
  
  def view_store(options={})
    Rddb::ViewStore::FilesystemViewStore.new(
      {
        :basedir => File.dirname(__FILE__) + '/../tmp/integration/views'
      }.merge(options)
    )
  end
  
  def materialization_store(options={})
    Rddb::MaterializationStore::FilesystemMaterializationStore.new(
      {
        :basedir => File.dirname(__FILE__) + '/../tmp/integration/materializations'
      }.merge(options)
    )
  end
end