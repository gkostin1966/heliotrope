$(document).on('turbolinks:load', function () {
    if ($(".asset").length > 0 || (".monograph").length > 0) {
        displayNagBanner();
        closeNagBanner();
    }
});

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Display the Nag banner, but
// if the users chooses to ignore the nag banner or clicks the link to buy access
// don't show the banner again.

function displayNagBanner() {
    var nagBannerStatus = Cookies.get('nag_' + (new Date().getFullYear().toString()) + '_banner');
    if (( nagBannerStatus == 'ignore') || (nagBannerStatus == 'clicked')) {
        $("div.nag-banner").hide();
    } else {
        $("div.nag-banner").show();
    }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function closeNagBanner() {
    $(".nag-banner a.close").click(function() {
        $("div.nag-banner").hide();
    });

    $(".nag-banner a.btn-primary").click(function() {
        $("div.nag-banner").hide();
    });
}
