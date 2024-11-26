// // ignore_for_file: public_member_api_docs, library_private_types_in_public_api
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/collection_local_data_source.dart';
// import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/url_local_data_sources.dart';
// import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/collection_remote_data_source.dart';
// import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';
// import 'package:link_vault/core/common/repository_layer/repositories/global_auth_repo.dart';
// import 'package:link_vault/core/common/repository_layer/repositories/url_repo_impl.dart';
// import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
// import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
// import 'package:link_vault/src/search/data/local_data_source.dart';

// class DependencyProvider {
//   static FirebaseFirestore firestore = FirebaseFirestore.instance;
//   static FirebaseAuth auth = FirebaseAuth.instance;

//   static RemoteDataSourcesImpl remoteDataSource =
//       RemoteDataSourcesImpl(firestore: firestore);
//   static GlobalAuthDataSourceImpl globalAuthDataSource =
//       GlobalAuthDataSourceImpl();

//   static CollectionLocalDataSourcesImpl collectionLocalDataSources =
//       CollectionLocalDataSourcesImpl(isar: null);
//   static UrlLocalDataSourcesImpl urlLocalDataSources =
//       UrlLocalDataSourcesImpl(isar: null);
//   static SearchLocalDataSourcesImpl searchLocalDataSources =
//       SearchLocalDataSourcesImpl(isar: null);

//   static AuthRepositoryImpl authRepository = AuthRepositoryImpl(
//     authRemoteDataSourcesImpl: AuthRemoteDataSourcesImpl(
//       auth: auth,
//       globalAuthDataSourceImpl: globalAuthDataSource,
//     ),
//   );

//   static CollectionsRepoImpl collectionsRepo = CollectionsRepoImpl(
//     remoteDataSourceImpl: remoteDataSource,
//     collectionLocalDataSourcesImpl: collectionLocalDataSources,
//     urlLocalDataSourcesImpl: urlLocalDataSources,
//   );

//   static UrlRepoImpl urlRepo = UrlRepoImpl(
//     remoteDataSourceImpl: remoteDataSource,
//     collectionLocalDataSourcesImpl: collectionLocalDataSources,
//     urlLocalDataSourcesImpl: urlLocalDataSources,
//   );
// }
