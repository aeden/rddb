create_view('test', :materialization_store => materialization_store) do |document, args|
  document.name
end