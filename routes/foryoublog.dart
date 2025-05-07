import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/mediumuuu?query=fruit&pagecount=2
  final queryParams = context.request.uri.queryParameters;
  final query = queryParams['query'] ?? 'fruit';
  final pagecount = queryParams['pagecount'] ?? 1;
  final headers = {
    'Content-Type': 'application/json',
    'Cookie':
        '_cfuvid=7A2dpHVqlsrqIrO7ptvaiXCgzxpCuHWrV7Sbxhkz30U-1746618640621-0.0.1.1-604800000; sid=1:820c1UevA34Zf2KuRQ0PWVxzv6v322BWoZ+DtWFwgtD0qEaMRGye/3kMsf8rp2Vj; uid=lo_179dcf5c90c5'
  };
  final request =
      http.Request('POST', Uri.parse('https://medium.com/_/graphql'))
        ..body = jsonEncode([
          {
            'operationName': 'SearchQuery',
            'variables': {
              'query': query,
              'pagingOptions': {'limit': 20, 'page': pagecount},
              'withUsers': false,
              'withTags': false,
              'withPosts': true,
              'withCollections': false,
              'withLists': false,
              'peopleSearchOptions': {
                'filters':
                    'highQualityUser:true OR writtenByHighQulityUser:true',
                'numericFilters': 'peopleType!=2',
                'clickAnalytics': true,
                'analyticsTags': ['web-main-content']
              },
              'postsSearchOptions': {
                'filters': 'writtenByHighQualityUser:true',
                'clickAnalytics': true,
                'analyticsTags': ['web-main-content']
              },
              'publicationsSearchOptions': {
                'clickAnalytics': true,
                'analyticsTags': ['web-main-content']
              },
              'tagsSearchOptions': {
                'numericFilters': 'postCount>=1',
                'clickAnalytics': true,
                'analyticsTags': ['web-main-content']
              },
              'listsSearchOptions': {
                'clickAnalytics': true,
                'analyticsTags': ['web-main-content']
              },
              'searchInCollection': false,
              'collectionDomainOrSlug': 'medium.com'
            },
            'query':
                'query SearchQuery(\$query: String!, \$pagingOptions: SearchPagingOptions!, \$searchInCollection: Boolean!, \$collectionDomainOrSlug: String!, \$withUsers: Boolean!, \$withTags: Boolean!, \$withPosts: Boolean!, \$withCollections: Boolean!, \$withLists: Boolean!, \$peopleSearchOptions: SearchOptions, \$postsSearchOptions: SearchOptions, \$tagsSearchOptions: SearchOptions, \$publicationsSearchOptions: SearchOptions, \$listsSearchOptions: SearchOptions) {\n  search(query: \$query) @skip(if: \$searchInCollection) {\n    __typename\n    ...Search_search\n  }\n  searchInCollection(query: \$query, domainOrSlug: \$collectionDomainOrSlug) @include(if: \$searchInCollection) {\n    __typename\n    ...Search_search\n  }\n}\n\nfragment userUrl_user on User {\n  __typename\n  id\n  customDomainState {\n    live {\n      domain\n      __typename\n    }\n    __typename\n  }\n  hasSubdomain\n  username\n}\n\nfragment UserAvatar_user on User {\n  __typename\n  id\n  imageId\n  membership {\n    tier\n    __typename\n    id\n  }\n  name\n  username\n  ...userUrl_user\n}\n\nfragment UserFollowButtonSignedIn_user on User {\n  id\n  name\n  __typename\n}\n\nfragment SignInOptions_user on User {\n  id\n  name\n  __typename\n}\n\nfragment SignUpOptions_user on User {\n  id\n  name\n  __typename\n}\n\nfragment SusiContainer_user on User {\n  ...SignInOptions_user\n  ...SignUpOptions_user\n  __typename\n  id\n}\n\nfragment SusiClickable_user on User {\n  ...SusiContainer_user\n  __typename\n  id\n}\n\nfragment UserFollowButtonSignedOut_user on User {\n  id\n  ...SusiClickable_user\n  __typename\n}\n\nfragment UserFollowButton_user on User {\n  ...UserFollowButtonSignedIn_user\n  ...UserFollowButtonSignedOut_user\n  __typename\n  id\n}\n\nfragment useIsVerifiedBookAuthor_user on User {\n  verifications {\n    isBookAuthor\n    __typename\n  }\n  __typename\n  id\n}\n\nfragment UserFollowInline_user on User {\n  id\n  name\n  bio\n  mediumMemberAt\n  ...UserAvatar_user\n  ...UserFollowButton_user\n  ...userUrl_user\n  ...useIsVerifiedBookAuthor_user\n  __typename\n}\n\nfragment SearchPeople_people on SearchPeople {\n  items {\n    __typename\n    ... on User {\n      algoliaObjectId\n      __typename\n      id\n    }\n    ...UserFollowInline_user\n  }\n  queryId\n  __typename\n}\n\nfragment TopicPill_tag on Tag {\n  __typename\n  id\n  displayTitle\n  normalizedTagSlug\n}\n\nfragment SearchTags_tags on SearchTag {\n  items {\n    id\n    algoliaObjectId\n    ...TopicPill_tag\n    __typename\n  }\n  queryId\n  __typename\n}\n\nfragment StreamPostPreviewImage_imageMetadata on ImageMetadata {\n  id\n  focusPercentX\n  focusPercentY\n  alt\n  __typename\n}\n\nfragment StreamPostPreviewImage_post on Post {\n  title\n  previewImage {\n    ...StreamPostPreviewImage_imageMetadata\n    __typename\n    id\n  }\n  __typename\n  id\n}\n\nfragment SusiContainer_post on Post {\n  id\n  __typename\n}\n\nfragment SusiClickable_post on Post {\n  id\n  mediumUrl\n  ...SusiContainer_post\n  __typename\n}\n\nfragment MultiVoteCount_post on Post {\n  id\n  __typename\n}\n\nfragment MultiVote_post on Post {\n  id\n  creator {\n    id\n    ...SusiClickable_user\n    __typename\n  }\n  isPublished\n  ...SusiClickable_post\n  collection {\n    id\n    slug\n    __typename\n  }\n  isLimitedState\n  ...MultiVoteCount_post\n  __typename\n}\n\nfragment PostPreviewFooterSocial_post on Post {\n  id\n  ...MultiVote_post\n  allowResponses\n  isPublished\n  isLimitedState\n  postResponses {\n    count\n    __typename\n  }\n  __typename\n}\n\nfragment AddToCatalogBase_post on Post {\n  id\n  isPublished\n  ...SusiClickable_post\n  __typename\n}\n\nfragment AddToCatalogBookmarkButton_post on Post {\n  ...AddToCatalogBase_post\n  __typename\n  id\n}\n\nfragment BookmarkButton_post on Post {\n  visibility\n  ...SusiClickable_post\n  ...AddToCatalogBookmarkButton_post\n  __typename\n  id\n}\n\nfragment ClapMutation_post on Post {\n  __typename\n  id\n  clapCount\n  ...MultiVoteCount_post\n}\n\nfragment OverflowMenuItemUndoClaps_post on Post {\n  id\n  clapCount\n  ...ClapMutation_post\n  __typename\n}\n\nfragment NegativeSignalModal_publisher on Publisher {\n  __typename\n  id\n  name\n}\n\nfragment NegativeSignalModal_post on Post {\n  id\n  creator {\n    ...NegativeSignalModal_publisher\n    viewerEdge {\n      id\n      isMuting\n      __typename\n    }\n    __typename\n    id\n  }\n  collection {\n    ...NegativeSignalModal_publisher\n    viewerEdge {\n      id\n      isMuting\n      __typename\n    }\n    __typename\n    id\n  }\n  __typename\n}\n\nfragment ExplicitSignalMenuOptions_post on Post {\n  ...NegativeSignalModal_post\n  __typename\n  id\n}\n\nfragment OverflowMenu_post on Post {\n  id\n  creator {\n    id\n    __typename\n  }\n  collection {\n    id\n    __typename\n  }\n  ...OverflowMenuItemUndoClaps_post\n  ...AddToCatalogBase_post\n  ...ExplicitSignalMenuOptions_post\n  __typename\n}\n\nfragment OverflowMenuButton_post on Post {\n  id\n  visibility\n  ...OverflowMenu_post\n  __typename\n}\n\nfragment PostPreviewFooterMenu_post on Post {\n  id\n  ...BookmarkButton_post\n  ...OverflowMenuButton_post\n  __typename\n}\n\nfragment usePostPublishedAt_post on Post {\n  firstPublishedAt\n  latestPublishedAt\n  pinnedAt\n  __typename\n  id\n}\n\nfragment Star_post on Post {\n  id\n  creator {\n    id\n    __typename\n  }\n  isLocked\n  __typename\n}\n\nfragment PostPreviewFooterMeta_post on Post {\n  isLocked\n  postResponses {\n    count\n    __typename\n  }\n  ...usePostPublishedAt_post\n  ...Star_post\n  __typename\n  id\n}\n\nfragment PostPreviewFooter_post on Post {\n  ...PostPreviewFooterSocial_post\n  ...PostPreviewFooterMenu_post\n  ...PostPreviewFooterMeta_post\n  __typename\n  id\n}\n\nfragment UserMentionTooltip_user on User {\n  id\n  name\n  bio\n  ...UserAvatar_user\n  ...UserFollowButton_user\n  ...useIsVerifiedBookAuthor_user\n  __typename\n}\n\nfragment UserName_user on User {\n  name\n  ...useIsVerifiedBookAuthor_user\n  ...userUrl_user\n  ...UserMentionTooltip_user\n  __typename\n  id\n}\n\nfragment PostPreviewByLineAuthor_user on User {\n  ...UserMentionTooltip_user\n  ...UserAvatar_user\n  ...UserName_user\n  __typename\n  id\n}\n\nfragment collectionUrl_collection on Collection {\n  id\n  domain\n  slug\n  __typename\n}\n\nfragment CollectionAvatar_collection on Collection {\n  name\n  avatar {\n    id\n    __typename\n  }\n  ...collectionUrl_collection\n  __typename\n  id\n}\n\nfragment SignInOptions_collection on Collection {\n  id\n  name\n  __typename\n}\n\nfragment SignUpOptions_collection on Collection {\n  id\n  name\n  __typename\n}\n\nfragment SusiContainer_collection on Collection {\n  name\n  ...SignInOptions_collection\n  ...SignUpOptions_collection\n  __typename\n  id\n}\n\nfragment SusiClickable_collection on Collection {\n  ...SusiContainer_collection\n  __typename\n  id\n}\n\nfragment CollectionFollowButton_collection on Collection {\n  __typename\n  id\n  name\n  slug\n  ...collectionUrl_collection\n  ...SusiClickable_collection\n}\n\nfragment EntityPresentationRankedModulePublishingTracker_entity on RankedModulePublishingEntity {\n  __typename\n  ... on Collection {\n    id\n    __typename\n  }\n  ... on User {\n    id\n    __typename\n  }\n}\n\nfragment CollectionTooltip_collection on Collection {\n  id\n  name\n  slug\n  description\n  subscriberCount\n  customStyleSheet {\n    header {\n      backgroundImage {\n        id\n        __typename\n      }\n      __typename\n    }\n    __typename\n    id\n  }\n  ...CollectionAvatar_collection\n  ...CollectionFollowButton_collection\n  ...EntityPresentationRankedModulePublishingTracker_entity\n  __typename\n}\n\nfragment CollectionLinkWithPopover_collection on Collection {\n  name\n  ...collectionUrl_collection\n  ...CollectionTooltip_collection\n  __typename\n  id\n}\n\nfragment PostPreviewByLineCollection_collection on Collection {\n  ...CollectionAvatar_collection\n  ...CollectionTooltip_collection\n  ...CollectionLinkWithPopover_collection\n  __typename\n  id\n}\n\nfragment PostPreviewByLine_post on Post {\n  creator {\n    ...PostPreviewByLineAuthor_user\n    __typename\n    id\n  }\n  collection {\n    ...PostPreviewByLineCollection_collection\n    __typename\n    id\n  }\n  __typename\n  id\n}\n\nfragment PostPreviewInformation_post on Post {\n  readingTime\n  isLocked\n  ...Star_post\n  ...usePostPublishedAt_post\n  __typename\n  id\n}\n\nfragment StreamPostPreviewContent_post on Post {\n  id\n  title\n  previewImage {\n    id\n    __typename\n  }\n  extendedPreviewContent {\n    subtitle\n    __typename\n  }\n  ...StreamPostPreviewImage_post\n  ...PostPreviewFooter_post\n  ...PostPreviewByLine_post\n  ...PostPreviewInformation_post\n  __typename\n}\n\nfragment PostScrollTracker_post on Post {\n  id\n  collection {\n    id\n    __typename\n  }\n  sequence {\n    sequenceId\n    __typename\n  }\n  __typename\n}\n\nfragment usePostUrl_post on Post {\n  id\n  creator {\n    ...userUrl_user\n    __typename\n    id\n  }\n  collection {\n    id\n    domain\n    slug\n    __typename\n  }\n  isSeries\n  mediumUrl\n  sequence {\n    slug\n    __typename\n  }\n  uniqueSlug\n  __typename\n}\n\nfragment PostPreviewContainer_post on Post {\n  id\n  extendedPreviewContent {\n    isFullContent\n    __typename\n  }\n  visibility\n  pinnedAt\n  ...PostScrollTracker_post\n  ...usePostUrl_post\n  __typename\n}\n\nfragment StreamPostPreview_post on Post {\n  id\n  ...StreamPostPreviewContent_post\n  ...PostPreviewContainer_post\n  __typename\n}\n\nfragment SearchPosts_posts on SearchPost {\n  items {\n    id\n    algoliaObjectId\n    ...StreamPostPreview_post\n    __typename\n  }\n  queryId\n  __typename\n}\n\nfragment CollectionFollowInline_collection on Collection {\n  id\n  name\n  domain\n  shortDescription\n  slug\n  ...CollectionAvatar_collection\n  ...CollectionFollowButton_collection\n  __typename\n}\n\nfragment usePublicationSearchResultClickTracker_collection on Collection {\n  id\n  algoliaObjectId\n  domain\n  slug\n  __typename\n}\n\nfragment SearchCollections_collection on Collection {\n  id\n  ...CollectionFollowInline_collection\n  ...usePublicationSearchResultClickTracker_collection\n  __typename\n}\n\nfragment SearchCollections_collections on SearchCollection {\n  items {\n    ...SearchCollections_collection\n    __typename\n  }\n  queryId\n  __typename\n}\n\nfragment getCatalogSlugId_Catalog on Catalog {\n  id\n  name\n  __typename\n}\n\nfragment formatItemsCount_catalog on Catalog {\n  postItemsCount\n  __typename\n  id\n}\n\nfragment PreviewCatalogCovers_catalogItemV2 on CatalogItemV2 {\n  catalogItemId\n  entity {\n    __typename\n    ... on Post {\n      visibility\n      previewImage {\n        id\n        alt\n        __typename\n      }\n      __typename\n      id\n    }\n  }\n  __typename\n}\n\nfragment CatalogsListItemCovers_catalog on Catalog {\n  listItemsConnection: itemsConnection(pagingOptions: {limit: 10}) {\n    items {\n      catalogItemId\n      ...PreviewCatalogCovers_catalogItemV2\n      __typename\n    }\n    __typename\n  }\n  __typename\n  id\n}\n\nfragment catalogUrl_catalog on Catalog {\n  id\n  predefined\n  ...getCatalogSlugId_Catalog\n  creator {\n    ...userUrl_user\n    __typename\n    id\n  }\n  __typename\n}\n\nfragment CatalogContentNonCreatorMenu_catalog on Catalog {\n  id\n  viewerEdge {\n    clapCount\n    __typename\n    id\n  }\n  ...catalogUrl_catalog\n  __typename\n}\n\nfragment UpdateCatalogDialog_catalog on Catalog {\n  id\n  name\n  description\n  visibility\n  type\n  __typename\n}\n\nfragment CatalogContentCreatorMenu_catalog on Catalog {\n  id\n  visibility\n  name\n  description\n  type\n  postItemsCount\n  predefined\n  disallowResponses\n  creator {\n    ...userUrl_user\n    __typename\n    id\n  }\n  ...UpdateCatalogDialog_catalog\n  ...catalogUrl_catalog\n  __typename\n}\n\nfragment CatalogContentMenu_catalog on Catalog {\n  creator {\n    ...userUrl_user\n    __typename\n    id\n  }\n  ...CatalogContentNonCreatorMenu_catalog\n  ...CatalogContentCreatorMenu_catalog\n  __typename\n  id\n}\n\nfragment SaveCatalogButton_catalog on Catalog {\n  id\n  creator {\n    id\n    username\n    __typename\n  }\n  viewerEdge {\n    id\n    isFollowing\n    __typename\n  }\n  ...getCatalogSlugId_Catalog\n  __typename\n}\n\nfragment CatalogsListItem_catalog on Catalog {\n  id\n  name\n  predefined\n  visibility\n  creator {\n    imageId\n    name\n    ...userUrl_user\n    ...useIsVerifiedBookAuthor_user\n    __typename\n    id\n  }\n  ...getCatalogSlugId_Catalog\n  ...formatItemsCount_catalog\n  ...CatalogsListItemCovers_catalog\n  ...CatalogContentMenu_catalog\n  ...SaveCatalogButton_catalog\n  __typename\n}\n\nfragment SearchLists_catalogs on SearchCatalog {\n  items {\n    id\n    algoliaObjectId\n    ...CatalogsListItem_catalog\n    __typename\n  }\n  queryId\n  __typename\n}\n\nfragment Search_search on Search {\n  people(pagingOptions: \$pagingOptions, algoliaOptions: \$peopleSearchOptions) @include(if: \$withUsers) {\n    ... on SearchPeople {\n      pagingInfo {\n        next {\n          limit\n          page\n          __typename\n        }\n        __typename\n      }\n      ...SearchPeople_people\n      __typename\n    }\n    __typename\n  }\n  tags(pagingOptions: \$pagingOptions, algoliaOptions: \$tagsSearchOptions) @include(if: \$withTags) {\n    ... on SearchTag {\n      pagingInfo {\n        next {\n          limit\n          page\n          __typename\n        }\n        __typename\n      }\n      ...SearchTags_tags\n      __typename\n    }\n    __typename\n  }\n  posts(pagingOptions: \$pagingOptions, algoliaOptions: \$postsSearchOptions) @include(if: \$withPosts) {\n    ... on SearchPost {\n      pagingInfo {\n        next {\n          limit\n          page\n          __typename\n        }\n        __typename\n      }\n      ...SearchPosts_posts\n      __typename\n    }\n    __typename\n  }\n  collections(\n    pagingOptions: \$pagingOptions\n    algoliaOptions: \$publicationsSearchOptions\n  ) @include(if: \$withCollections) {\n    ... on SearchCollection {\n      pagingInfo {\n        next {\n          limit\n          page\n          __typename\n        }\n        __typename\n      }\n      ...SearchCollections_collections\n      __typename\n    }\n    __typename\n  }\n  catalogs(pagingOptions: \$pagingOptions, algoliaOptions: \$listsSearchOptions) @include(if: \$withLists) {\n    ... on SearchCatalog {\n      pagingInfo {\n        next {\n          limit\n          page\n          __typename\n        }\n        __typename\n      }\n      ...SearchLists_catalogs\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n'
          }
        ]);
  request.headers.addAll(headers);

  try {
    final streamedResponse = await request.send();

    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);

      if (data is List && data.isNotEmpty) {
        final resultJson = data[0];
        return Response.json(
          body: jsonEncode(resultJson),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      } else {
        return Response.json(
          body: jsonEncode({'error': 'API数据为空.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } else {
      return Response.json(
          body: jsonEncode(
              {'error': '请求API失败.', 'details': jsonDecode(responseBody)}),
          headers: {'Content-Type': 'application/json'});
    }
  } catch (e) {
    return Response.json(
      body: jsonEncode({
        'error': '发送时候报错了',
        'details': e.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
