// Custom javascript cell renderer for podcast column
function renderPodcastEntry(cellInfo) {
  const podcastindex_url = 'https://podcastindex.org/podcast/' + cellInfo.row['id']
  const image_url = cellInfo.row['imageUrl']
  const podcastImage = '<a href="${url}"><img src="${image_url}"></a>'
  const title = '<a href="${url}">${cellInfo.value}</a>'
  const category = cellInfo.row['category']
  const rss_url = cellInfo.row['url']
  const podcastguid = cellInfo.row['podcastGuid']
  const newestItemEpoch = cellInfo.row['newestItemPubdate']
  const lastUpdateEpoch = cellInfo.row['lastUpdate']

  
  let author = cellInfo.row['itunesAuthor']
  if (author) {
    author = '<span class="podcast-author">${author}</span>'
  } else {
    author = ''
  }

  newestItemTimestamp = Date(newestItemEpoch * 1000).toGMTString()
  lastUpdateTimestamp = Date(lastUpdateEpoch * 1000).toGMTString()

  
}