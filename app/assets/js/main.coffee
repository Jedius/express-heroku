window.glob = glob = {}
glob.sessionTime = null
glob.url = location.protocol + "//" + location.host
glob.emailRegExp = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/

if !Array.indexOf
    Array.prototype.indexOf = (obj)->
        for el,i in this
            return i if el is obj
        return -1

glob = window.glob

glob.authValidate = (req, min, max) ->
  min = 6  unless min
  max = 30  unless max
  if req.email.match(glob.emailRegExp) and req.password.length >= min and req.password.length < max
    return true
  else
    return false

auth = (e)->
    req = 
        email: $('#authEmail input').val() or ""
        password: $('#authPassword input').val() or ""
        ajax: true
    return false unless glob.authValidate(req)
    $('#authEmail').removeClass('success').removeClass('error').find('.help-block').text('').hide()
    $('#authPassword').removeClass('success').removeClass('error').find('.help-block').text('').hide()
    $.get glob.url + '/auth/'+$(this).attr('id'), req, (res) ->
        if res.redirect
            window.location = res.redirect
        else if res.errors
            for error in res.errors
                switch error[0]
                    when 'email'
                        $('#authEmail')
                            .removeClass('success')
                            .addClass('error')
                            .find('.help-block')
                            .text(error[1])
                            .fadeIn 500
                    when 'password'
                        $('#authPassword')
                            .removeClass('success')
                            .addClass('error')
                            .find('.help-block')
                            .text(error[1])
                            .fadeIn 500
                    else
                        $('#authEmail')
                            .removeClass('success')
                            .addClass('error')
                            .find('.help-block')
                            .text(error[1])
                            .fadeIn 500
        else
            location.reload true
    return false

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

$('#facebook').live 'click', ->
    window.location = '/auth/facebook'
    return false
$('#twitter').live 'click', ->
    window.location = '/auth/twitter'
    return false
$('#linkedIn').live 'click', ->
    window.location = '/auth/linkedin'
    return false


$('#logout').live 'click', ->
    window.location = '/logout'

$('#authEmail input').live 'blur', checkAuthEmail
$('#authPassword input').live 'blur', checkAuthPassword
$('.btn-auth').live 'click', auth


$('#terms').live 'click', showTerms


$(document).ready ->

    if $.browser.msie and parseInt($.browser.version, 10) is 6
        $('.row div[class^=\'span\']:last-child').addClass 'last-child'
        $('[class=\'span\']').addClass 'margin-left-20'
        $(':button[class=\'btn\'], :reset[class=\'btn\'], :submit[class=\'btn\'], input[type=\'button\']').addClass 'button-reset'
        $(':checkbox').addClass 'input-checkbox'
        $('[class^=\'icon-\'], [class=\' icon-\']').addClass 'icon-sprite'
        $('.pagination li:first-child a').addClass 'pagination-first-child'
