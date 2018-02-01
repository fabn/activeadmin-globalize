$ ->

  translations = ->

    # Hides or shows the + button and the remove button.
    updateLocaleButtonsStatus = ($dom) ->
      $localeList = $dom.find('.add-locale ul li:not(.hidden)')
      if $localeList.length == 0
        $dom.find('.add-locale').hide()
      else
        $dom.find('.add-locale').show()


    # Hides or shows the locale tab and its corresponding element in the add menu.
    toggleTab = ($tab, active) ->
      $addButton = $tab.parents('ul').find('.add-locale li:has(a[href="' + $tab.attr('href') + '"])')
      if active
        $tab.addClass('hidden').show().removeClass('hidden')
        $addButton.hide().addClass('hidden')
      else
        $tab.addClass('hidden').hide().addClass('hidden')
        $addButton.show().removeClass('hidden')

    $(".activeadmin-translations > ul").each ->
      $dom = $(this)
      # true when tabs are used in show action, false in form
      showAction = $dom.hasClass('locale-selector')

      if !$dom.data("ready")
        $dom.data("ready", true)
        $tabs = $("li > a", this)
        # content to toggle is different according to current action
        $contents = if showAction then $(this).siblings("div.field-translation") else $(this).siblings("fieldset")

        $tabs.click (e) ->
          $tab = $(this)
          $tabs.not($tab).removeClass("active")
          $tab.addClass("active")
          $contents.hide()
          $contents.filter($tab.attr("href")).show()
          e.preventDefault()

        $tabs.eq(0).click()

        # Add button and other behavior is not needed in show action
        return if showAction

        # Collect tha available locales.
        availableLocales = []
        $tabs.not('.default').each ->
          availableLocales.push($('<li></li>').append($(this).clone().removeClass('active')))

        # Create a new tab as the root of the drop down menu.
        $addLocaleButton = $('<li class="add-locale"><a href="#">+</a></li>')
        $addLocaleButton.append($('<ul></ul>').append(availableLocales))

        # Handle locale addition
        $addLocaleButton.find('ul a').click (e) ->
          href = $(this).attr('href')
          $tab = $tabs.filter('[href="' + href + '"]')
          toggleTab($tab, true)
          $tab.click()
          updateLocaleButtonsStatus($dom)
          e.preventDefault()

        # Remove a locale from the tab.
        $removeButton = $('<span class="remove">x</span>').click (e) ->
          e.stopImmediatePropagation()
          e.preventDefault()
          $tab = $(this).parent()
          toggleTab($tab, false)
          if $tab.hasClass('active')
            $tabs.not('.hidden').eq(0).click()

          updateLocaleButtonsStatus($dom)

        # Add the remove button to every tab.
        $tabs.not('.default').append($removeButton)

        # Add the new button at the end of the locale list.
        $dom.append($addLocaleButton)

        $tabs.each ->
          $tab = $(@)
          $content = $contents.filter($tab.attr("href"))
          containsErrors = $content.find(".input.error").length > 0
          $tab.toggleClass("error", containsErrors)
          # Find those tabs that are in use.
          hide = true
          # We will not hide the tabs that have any error.
          if $tab.hasClass('error') || $tab.hasClass('default')
            hide = false
          else
            # Check whether the input fields are empty or not.
            $content.find('[name]').not('[type="hidden"]').each ->
              if $(this).val()
                # We will not hide the tab because it has some data.
                hide = false
                return false

          if hide
            toggleTab($tab, false)
          else
            toggleTab($tab, true)

        # Remove the fields of hidden locales before form submission.
        $form = $dom.parents('form')
        if !$form.data('ready')
          $form.data('ready')
          $form.submit ->
            # Get all translations (the nested ones too).
            $('.activeadmin-translations > ul').each ->
              # Get the corresponding fieldsets.
              $fieldsets = $(this).siblings('fieldset')
              $("li:not(.add-locale) > a", this).each ->
                # Remove them if the locale is hidden.
                if $(this).hasClass('hidden')
                  # check if it's an existing translation otherwise remove it
                  $currentFieldset = $("fieldset#{$(this).attr('href')}")
                  $translationId = $('input[id$=_id]', $currentFieldset)
                  if $translationId.val()
                    # mark it for database removal appending a _destroy element
                    $destroy = $('<input/>').attr(
                      type: 'hidden',
                      name: $translationId.attr('name').replace('[id]', '[_destroy]'),
                      id: $translationId.attr('id').replace('_id', '_destroy'),
                      value: '1'
                    )
                    $destroy.appendTo($currentFieldset)
                  else
                    # remove the fieldset from dom so it won't be submitted
                    $fieldsets.filter($(this).attr('href')).remove()

        #Initially update the buttons' status
        updateLocaleButtonsStatus($dom)
        $tabs.filter('.default').click()

  # this is to handle elements created with has_many
  $("a").on "click", ->
    setTimeout(
      -> translations()
      50
    )

  # Used to toggle translations values for inline fields
  $('a.ui-translation-trigger').click (e) ->
    $locale = $(this).data('locale')
    $td = $(this).closest('td')
    $('.field-translation', $td).hide()
    $(".locale-#{$locale}", $td).show()
    $(this).parent().children('a.ui-translation-trigger').removeClass('active')
    $(this).addClass('active')
    e.preventDefault()

  translations()
