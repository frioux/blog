function toggleTheme() {
    if (localStorage.getItem('b+w')) {
        localStorage.setItem('b+w', '');
        window.location.reload(true);
    } else {
        localStorage.setItem('b+w', 1);
        plainTheme();
    }
}

function plainTheme() {
    var file = location.pathname.split( "/" ).pop();

    var link = document.createElement( "link" );
    link.href = "/static/css/styles-inverted.css";
    link.type = "text/css";
    link.rel = "stylesheet";

    document.getElementsByTagName( "head" )[0].appendChild( link );
    document.getElementById( "toggleTheme" ).innerText = '🎃';
}

window.onload = function() {
    if (localStorage.getItem('b+w')) {
        plainTheme()
    }
};
