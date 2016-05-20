function toggleTheme() {
    if (localStorage.getItem('b+w')) {
        localStorage.setItem('b+w', '');
        applyTheme('styles', '💡')
    } else {
        localStorage.setItem('b+w', 1);
        applyTheme('styles-inverted', '🎃')
    }
}

function applyTheme(style, label) {
    var file = location.pathname.split( "/" ).pop();

    var link = document.createElement( "link" );
    link.href = "/static/css/" + style + ".css";
    link.type = "text/css";
    link.rel = "stylesheet";

    document.getElementsByTagName( "head" )[0].appendChild( link );
    document.getElementById( "toggleTheme" ).innerText = label;
}

window.onload = function() {
    if (localStorage.getItem('b+w')) {
        applyTheme('styles-inverted')
    }
};
