/**
 * We need to add a class of `responsive-nav--open` to
 * `#js-responsive-nav` ONLY when the nav is clicked AND
 * when we’re on a viewport of less than `responsiveNavBreakpoint`.
 * It needs removing when someone re-clicks the nav icon, or
 * when the viewport no longer matches `responsiveNavBreakpoint`.
 */

$(document).ready(function() {
    var responsiveNav = document.getElementById('js-responsive-nav');
    var responsiveNavBreakpoint = 720;

    responsiveNav.addEventListener('click', function(){
        if(window.innerWidth < responsiveNavBreakpoint){
           responsiveNav.classList.toggle("is-open");
        }
    })
});
