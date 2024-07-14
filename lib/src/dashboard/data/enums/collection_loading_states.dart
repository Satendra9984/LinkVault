// ignore_for_file: public_member_api_docs

enum CollectionLoadingStates {
  initial,

  // fetch
  fetching,
  errorLoading,
  successLoading,
  
  // update
  updating,
  errorUpdating,
  successUpdating,

  // delete
  deleting,
  errorDeleting,
  successDeleting,

  // add
  adding,
  errorAdding,
  successAdding,
}
