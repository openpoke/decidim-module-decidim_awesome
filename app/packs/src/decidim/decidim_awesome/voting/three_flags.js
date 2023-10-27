$(() => {
  if ($(".voting-three-flags").length === 0) {
    return;
  }

  const $modal = $("#threeFlagsModalHelp");

  $modal.find(".vote-action").on("click", () => {
    $modal.data("action").click();
    $modal.foundation("close");
  });

  $(".voting-three-flags").on("click", ".vote-action", (evt) => {
    if ($modal.is(":visible")) {
      return;
    }
    evt.stopPropagation();
    evt.preventDefault();
    $modal.data("action", evt.target)
    $modal.foundation("open")
  });
});
