$(() => {
  if ($(".voting-three-flags").length === 0 || $("#threeFlagsModalHelp").length === 0 || $(".sign-out-link").length === 0) {
    return;
  }

  const $modal = $("#threeFlagsModalHelp");
  const $card = $modal.find(".current-choice .vote-card");
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
      $modal.data("action", evt.currentTarget);
      $card[0].classList = evt.currentTarget.classList + ["voted"];
      if (evt.currentTarget.children.length > 1) {
        $card.html(`${evt.currentTarget.children[1].outerHTML}<p class="vote-label">${evt.currentTarget.children[1].children[0].textContent}</p>`);
      } else if ($card[0].classList.contains("button")) {
        $card[0].classList.remove("button");
        $card.html(`<p class="vote-label">${evt.currentTarget.title}</p>`);
      } else {
        $card.html(`<p class="vote-label">${evt.currentTarget.textContent}</p>`);
      }
      $modal.foundation("open");
    } else {
      $(evt.currentTarget).closest(".voting-three-flags").addClass("loading");
    }
  });
});
