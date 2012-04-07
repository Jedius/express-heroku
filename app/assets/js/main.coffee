glob = {}
glob.sessionTime = null
glob.url = location.protocol + "//" + location.host
glob.keys = 
    facebook: '263674280393348'
glob.emailRegExp = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/

glob.authValidate = (req, min, max) ->
  min = 6  unless min
  max = 30  unless max
  if req.email.match(glob.emailRegExp) and req.password.length >= min and req.password.length < max
    return true
  else
    return false

glob.update = (html, target) ->
  $(target).fadeOut 500, ->
    $(target).html html
    $(target).fadeIn 500


try
    if location.hash.split("#")[1].split("&")[0].split("=")[0] is "access_token"
        $(document).ready ->
            $('#popup').fadeIn()
        $.get '/ajax/auth/facebook', token: location.hash.split('#')[1].split('&')[0].split('=')[1], (res) ->
            if res
                $('#popup').fadeOut()
                location.hash = ''
                glob.update res, '#body'

getFacebookToken = (e)->
    $('#popup').fadeIn()
    window.location = 'https://www.facebook.com/dialog/oauth?client_id=' + glob.keys.facebook + '&redirect_uri=' + glob.url + '&response_type=token'
    return false

auth = (e)->
    action = $(this).attr('id')
    switch action
        when 'twitter'
            $('#popup').fadeIn 700
        when 'signIn','signUp'
            req = 
                email: $('#authEmail input').val() or ""
                password: $('#authPassword input').val() or ""
            return false unless glob.authValidate(req)
        else
            return false
    $.get glob.url + '/ajax/auth/'+action, req, (res) ->
        if res.redirect
            window.location = res.redirect
        if res.errors
            if res.errors.combination
                $('#authEmail, #authPassword')
                    .removeClass('success')
                    .addClass('error')
                    .find('.help-block')
                    .text('Wrong combination')
                    .fadeIn 500
            else if res.errors.exist
                $('#authEmail')
                    .removeClass('success')
                    .addClass('error')
                    .find('.help-block')
                    .text('This email already exist')
                    .fadeIn 500
            else if res.errors.email
                $('#authEmail')
                    .removeClass('success')
                    .addClass('error')
                    .find('.help-block')
                    .text('Invalid email')
                    .fadeIn 500
            else if res.errors.password
                $('#authPassword')
                    .removeClass('success')
                    .addClass('error')
                    .find('.help-block')
                    .text(res.errors.password)
                    .fadeIn 500
            else if res.errors.db
                $('#authEmail')
                    .removeClass('success')
                    .addClass('error')
                    .find('.help-block')
                    .text('Server error, try later')
                    .fadeIn 500
            else 
                $('#authEmail')
                    .removeClass('success')
                    .addClass('error')
                    .find('.help-block')
                    .text('Unknown error, try later')
                    .fadeIn 500
        else
            glob.update (res), '#body'
    return false

logout = (e)->
    $.get glob.url + '/ajax/auth/logout', $.cookie('sid'), (html) ->
      #$.cookie 'sid', null
      glob.update html, '#body'

checkAuthEmail = (e)->
    email = $(this).val() or ''
    if email.match(glob.emailRegExp)
      $('#authEmail').removeClass('error').addClass('success').find('.help-block').fadeOut 500
    else
      $('#authEmail').removeClass('success').addClass('error').find('.help-block').text('Please enter a valid email address').fadeIn 500

checkAuthPassword = (e)->
    password = $(this).val() or ''
    if password.length < 6
      $('#authPassword').removeClass('success').addClass('error').find('.help-block').text('Password must have at least 6 characters').fadeIn 500
    else if password.length >= 30
      $('#authPassword').removeClass('success').addClass('error').find('.help-block').text('The password is too long').fadeIn 500
    else
      $('#authPassword').removeClass('error').addClass('success').find('.help-block').fadeOut 500

showTerms = (e)->
    alert '1st rule - the admin is always right.\n2nd rule - if the admin is not right, see 1st rule!'



$('#facebook').live 'click', getFacebookToken

$('#authEmail input').live 'blur', checkAuthEmail
$('#authPassword input').live 'blur', checkAuthPassword
$('.btn-auth').live 'click', auth

$('#logout').live 'click', logout

$('#terms').live 'click', showTerms


$(document).ready ->


  if $.browser.msie and parseInt($.browser.version, 10) is 6
    $('.row div[class^=\'span\']:last-child').addClass 'last-child'
    $('[class=\'span\']').addClass 'margin-left-20'
    $(':button[class=\'btn\'], :reset[class=\'btn\'], :submit[class=\'btn\'], input[type=\'button\']').addClass 'button-reset'
    $(':checkbox').addClass 'input-checkbox'
    $('[class^=\'icon-\'], [class=\' icon-\']').addClass 'icon-sprite'
    $('.pagination li:first-child a').addClass 'pagination-first-child'

