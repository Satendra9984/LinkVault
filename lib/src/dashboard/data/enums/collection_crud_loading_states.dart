// ignore_for_file: public_member_api_docs

enum CollectionCrudLoadingStates {
  initial,

  // add states
  adding,
  errorAdding,
  addedSuccessfully,

  // update states
  updating,
  errorupdating,
  updatedSuccessfully,

  // delete states
  deleting,
  errordeleting,
  deletedSuccessfully,
}
