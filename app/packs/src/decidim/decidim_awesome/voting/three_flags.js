$(() => {
  if ($(".voting-three-flags").length === 0) {
    return;
  }

  const $modal = $("#threeFlagsModalHelp");
  const $check = $("#three_flag-skip_help");

  const storage = () => {
    return JSON.parse(localStorage.getItem("hideTreeFlagsModalHelp") || "{}")
  };

  const isChecked = () => {
    return storage()[$check.val()];
  };

  const saveState = (val) => {
    const show = storage();
    show[$check.val()] = val;
    localStorage.setItem("hideTreeFlagsModalHelp", JSON.stringify(show))
  };

  const showModal = () => {
    if (isChecked()) {
      return false;
    }
    if ($modal.is(":visible")) {
      return false;
    }
    return true;
  };

  $check.on("change", () => {
    saveState($check.is(":checked"))
  });

  $modal.find(".vote-action").on("click", () => {
    $modal.data("action").click();
    $modal.foundation("close");
  });

  $(".voting-three-flags").on("click", ".vote-action", (evt) => {
    if (showModal()) {
      evt.stopPropagation();
      evt.preventDefault();
      $check.prop("checked", isChecked());
      $modal.data("action", evt.target)
      $modal.foundation("open")
    }
  });
});
