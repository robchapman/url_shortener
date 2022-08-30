window.addEventListener("load", () => {
  const form = document.querySelector('#url-form');
  const list = document.querySelector('.url-list');
  form.addEventListener("ajax:success", (event) => {
    const [data] = event.detail;
    const shortenedUrl = form.dataset.rooturl + data.short_url;
    addURLToList(list, shortenedUrl)
  });
});

const addURLToList = (list, url) => {
  const link = document.createElement('a');
  link.href = url;
  link.textContent = url;
  listItem = document.createElement('li');
  listItem.appendChild(link);
  list.appendChild(listItem);
}