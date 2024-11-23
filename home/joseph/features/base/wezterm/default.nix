{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = {}

      config.default_prog = {
        '${pkgs.fish}/bin/fish', '-l'
      }

      config.font = wezterm.font 'Iosevka Term'
      config.initial_cols = 140
      config.initial_rows = 40

      -- Visual bell
      config.audible_bell = 'Disabled'
      config.visual_bell = {
        target = "CursorColor",
        fade_in_function = "EaseIn",
        fade_in_duration_ms = 150,
        fade_out_function = "EaseOut",
        fade_out_duration_ms = 300,
      }

      config.leader = { key = 'a', mods = 'CTRL'}
      config.keys = {
        {
          key = '|',
          mods = 'LEADER|SHIFT',
          action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
        {
          key = 'a',
          mods = 'LEADER|CTRL',
          action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
        },
        -- Leader followed by Alt-F to maximize a pane
        {
          key = 'f',
          mods = 'ALT',
          action = wezterm.action.TogglePaneZoomState,
        },
      }
      config.set_environment_variables = {
        -- needed so that wezterm terminfo file is visible
        TERMINFO_DIRS = '/run/current-system/sw/share/terminfo',
      }
      config.term = 'wezterm'
      config.enable_kitty_keyboard = true

      -- SSH and domains
      config.default_domain = 'local'
      config.ssh_domains = wezterm.default_ssh_domains()
      for _, dom in ipairs(config.ssh_domains) do
        dom.assume_shell = 'Posix'
      end

      -- Returns a bool based on whether the host operating system's
      -- appearance is light or dark.
      function is_dark()
        -- wezterm.gui is not always available, depending on what
        -- environment wezterm is operating in. Just return true
        -- if it's not defined.
        if wezterm.gui then
          -- Some systems report appearance like "Dark High Contrast"
          -- so let's just look for the string "Dark" and if we find
          -- it assume appearance is dark.
          return wezterm.gui.get_appearance():find("Dark")
        end
        return true
      end

      if is_dark() then
        config.color_scheme = 'Catppuccin Frappe'
      else
        config.color_scheme = 'Catppuccin Latte'
      end

      -- Slightly transparent and blurred background
      config.window_background_opacity = 0.9
      config.macos_window_background_blur = 30
      -- Removes the title bar, leaving only the tab bar. Keeps
      -- the ability to resize by dragging the window's edges.
      -- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
      -- you want to keep the window controls visible and integrate
      -- them into the tab bar.
      -- config.window_decorations = 'RESIZE'
      -- config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'
      -- Sets the font for the window frame (tab bar)
      config.window_frame = {
        font = wezterm.font({ family = 'Iosevka Term', weight = 'Bold' }),
        font_size = 11,
      }

      local function segments_for_right_status(window, pane)
        local cwd_uri = pane:get_current_working_dir()
        if type(cwd_uri) == 'userdata' then
          return {
            -- current working dir
            cwd_uri.file_path,
            -- date/time
            wezterm.strftime('%a %b %-d %H:%M'),
            -- hostname
            cwd_uri.host or wezterm.hostname()
          }
        end
        return {}
      end

      wezterm.on('update-status', function(window, pane)
        local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
        local segments = segments_for_right_status(window, pane)

        local color_scheme = window:effective_config().resolved_palette
        -- Note the use of wezterm.color.parse here, this returns
        -- a Color object, which comes with functionality for lightening
        -- or darkening the colour (amongst other things).
        local bg = wezterm.color.parse(color_scheme.background)
        local fg = color_scheme.foreground

        -- Each powerline segment is going to be coloured progressively
        -- darker/lighter depending on whether we're on a dark/light colour
        -- scheme. Let's establish the "from" and "to" bounds of our gradient.
        local gradient_to, gradient_from = bg
        if is_dark() then
          gradient_from = gradient_to:lighten(0.2)
        else
          gradient_from = gradient_to:darken(0.2)
        end

        -- Yes, WezTerm supports creating gradients, because why not?! Although
        -- they'd usually be used for setting high fidelity gradients on your terminal's
        -- background, we'll use them here to give us a sample of the powerline segment
        -- colours we need.
        local gradient = wezterm.color.gradient(
          {
            orientation = 'Horizontal',
            colors = { gradient_from, gradient_to },
          },
          #segments -- only gives us as many colours as we have segments.
        )

        -- We'll build up the elements to send to wezterm.format in this table.
        local elements = {}

        for i, seg in ipairs(segments) do
          local is_first = i == 1

          if is_first then
            table.insert(elements, { Background = { Color = 'none' } })
          end
          table.insert(elements, { Foreground = { Color = gradient[i] } })
          table.insert(elements, { Text = SOLID_LEFT_ARROW })

          table.insert(elements, { Foreground = { Color = fg } })
          table.insert(elements, { Background = { Color = gradient[i] } })
          table.insert(elements, { Text = ' ' .. seg .. ' ' })
        end

        window:set_right_status(wezterm.format(elements))
      end)

      return config
    '';
  };
}
