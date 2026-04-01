
## TODOS
[TODO] : ADD ALREADY READ FEED SHOWCASE
<!-- [TODO] : FULL IMAGE SHOW UP ON SIDEWAYS BANNER IMAGES -->
<!-- [TODO] : SYNC WITH REMOTE DATABASE  (PREMIUM) -->
[TODO] : MORE NETWORK CONNECTIVITY SHOWUP
[TODO] : ADD SUPPORT FOR AUTODETECTING RSS LINKS (https://youtube.com/shorts/bYSF41mvPYA?si=Hrj_jrfJqEsEnzRU)


[TODO] : PLUGIN FOR MAYLAUNCHURL WARM UP FOR ANDROID AND IOS
         DONE ANDROID
         DONE IOS


class CollectionModel {
  CollectionModel({
    /*collection constructor  fields*/
  });

  final Id isarId;

  @Index()
  final String id; // will be used for remote database(supabase now) row id

  @Index()
  final String userId;

  final String? parentCollectionId;  // collections are nested,null for root collection
  final String name; // collection name
  final String? description;  // if user wants to
  final String iconJson;      // collection icon
  final String backgroundJson;  // some background details for ui

  @Index()
  final bool isPinned;  // works as favourites

  @Index()
  final bool isArchived;

  @Index()
  final int position;  // if user reordered it

  final String layoutType;  // grid, list etc. for child collections ui
  final String sortOrder;   // child collection sorting order
  final String visibility;  // may be they will be shared in future feature

  final int urlCount;      // collection store urls so their count
  final int totalClicks;   // for filtering purpose, most frequent sorting

  final String statusJson; 
  final String settingsJson;  // other general settings mainly will use for urls

  @Index()
  final DateTime createdAt;

  @Index()
  final DateTime updatedAt;

  @Index()
  final DateTime? lastAccessedAt; // for recent collection searching, filtering

}

