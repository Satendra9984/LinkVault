enum AuthenticationStates {
  initial,
  //
  signingIn,
  signedIn,
  errorSigningIn,

  //
  signingUp,
  signedUp,
  errorSigningUp,


  // 
  signingOut,
  signedOut,
  errorSigningOut,


  // 
  deletingAccount,
  deleted,
  errorDeleted,
}
