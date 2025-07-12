using System;
using System.Diagnostics;
using System.Linq;
using Gtk;

public class AudioTools
{
    private TextView outputTextView;

    public AudioTools()
    {
        Application.Init();

        // Create the main window
        var appVersion = "0.93";
        var window = new Window("AudioTools v" + appVersion);
        window.SetDefaultSize(400, 500);
        window.SetPosition(WindowPosition.Center);
        window.DeleteEvent += (o, args) => Application.Quit();

        // Create a vertical box to hold the buttons and text view
        var vbox = new VBox();


        // Create an HBox to hold the two buttons side by side
        var hbox = new HBox();

		var menuBar = new MenuBar();
		vbox.PackStart(menuBar, false, false, 0);
		
		var optionsMenuItem = new MenuItem("Options");
        menuBar.Add(optionsMenuItem);
        
        // Create Options submenu
        var optionsMenu = new Menu();
        optionsMenuItem.Submenu = optionsMenu;
        
        // Launch winetricks
		var winetricksItem = new MenuItem("Open Winetricks");
		winetricksItem.Activated += (sender, e) => {
			RunCommand("winetricks");
		};
		optionsMenu.Append(winetricksItem);
		
		// Launch winecfg
		var winecfgItem = new MenuItem("Open WINE config");
		winecfgItem.Activated += (sender, e) => {
			RunCommand("winecfg");
		};
		optionsMenu.Append(winecfgItem);
		
		// Launch wine uninstaller
		var wineuninstItem = new MenuItem("Open WINE programs");
		wineuninstItem.Activated += (sender, e) => {
			RunCommand("wine uninstaller");
		};
		optionsMenu.Append(wineuninstItem);
		
		// Check for updates
		var updateItem = new MenuItem("Check for Updates");
		updateItem.Activated += (sender, e) => 
        {
        	var yabridgeVersion = "";
	        var checkyabridgeVersion = "";
	        var checkAudioToolsVersion = "";
	        yabridgeVersion = RunCommandWithReturn("$HOME/.local/share/yabridge/yabridgectl --version");
        
	        checkyabridgeVersion = RunCommandWithReturn("wget -qO- https://api.github.com/repos/robbert-vdh/yabridge/releases/latest | jq -r '.tag_name'");
      		checkAudioToolsVersion = RunCommandWithReturn("wget -qO- https://api.github.com/repos/Heroin-Bob/AudioTools-for-Linux/releases/latest | jq -r '.tag_name'");
	        using (MessageDialog md = new MessageDialog(null,
	        DialogFlags.Modal,
	        MessageType.Info,
	        ButtonsType.Ok,
	        "yabridge version: " + yabridgeVersion.Replace("yabridgectl ","") + "\n" + "latest yabridge version: " + checkyabridgeVersion + "\n" + "AudioTools version: " + appVersion + "\n" + "Latest version: " + checkAudioToolsVersion.Replace("v","")))
	        {
	            md.Title = "Message";
	            md.Run();
	            md.Destroy();
	        }
        };
        
		optionsMenu.Append(updateItem);
		
		
        // Create a label
        var sammpleRateLabel = new Label("Sample Rate:");
        hbox.PackStart(sammpleRateLabel, false, false, 5);

        // Create a dropdown (ComboBox)
        var sampleComboBox = new ComboBoxText();
        sampleComboBox.AppendText("44100");
        sampleComboBox.AppendText("48000");
        hbox.PackStart(sampleComboBox, false, false, 5);

        vbox.PackStart(hbox, false, true, 5);

        // Create a button
        var sampleButton = new Button("Set Sample Rate");
        sampleButton.Clicked += (sender, e) =>
        {
            string selectedValue = sampleComboBox.ActiveText;
            string concatCommand = "pw-metadata -n settings 0 clock.force-rate " + selectedValue;
            RunCommand(concatCommand);
        };
        hbox.PackStart(sampleButton, false, false, 5);

        hbox = new HBox();

        // Create a label
        var bufferSizeLabel = new Label("Buffer Size:");
        hbox.PackStart(bufferSizeLabel, false, false, 5);

        // Create a dropdown (ComboBox)
        var bufferComboBox = new ComboBoxText();
        bufferComboBox.AppendText("16");
        bufferComboBox.AppendText("32");
        bufferComboBox.AppendText("64");
        bufferComboBox.AppendText("128");
        bufferComboBox.AppendText("256");
        bufferComboBox.AppendText("512");
        bufferComboBox.AppendText("1024");
        hbox.PackStart(bufferComboBox, false, false, 5);

        vbox.PackStart(hbox, false, true, 5);

        // Create a button
        var bufferButton = new Button("Set Buffer Size");
        bufferButton.Clicked += (sender, e) =>
        {
            string selectedValue = bufferComboBox.ActiveText;
            string concatCommand = "pw-metadata -n settings 0 clock.force-quantum " + selectedValue;
            RunCommand(concatCommand);
        };
        hbox.PackStart(bufferButton, false, false, 5);



        hbox = new HBox();

        // Create the buttons with customizable properties
        var syncButton = CreateButton("yabridgectl sync", 150, 50);
        syncButton.Clicked += (sender, e) => RunCommand("$HOME/.local/share/yabridge/yabridgectl sync");

        var statusButton = CreateButton("yabridgectl status", 150, 50);
        statusButton.Clicked += (sender, e) => RunCommand("$HOME/.local/share/yabridge/yabridgectl status");

        var pruneButton = CreateButton("yabridgectl prune", 150, 50);
        pruneButton.Clicked += (sender, e) => RunCommand("$HOME/.local/share/yabridge/yabridgectl sync --prune");

        hbox.PackStart(syncButton, true, true, 5);
        hbox.PackStart(statusButton, true, true, 5);
        hbox.PackStart(pruneButton, true, true, 5);

        vbox.PackStart(hbox, false, false, 5);

        // Add the buttons to the horizontal box


        // Create the Clear button
        var clearButton = CreateButton("Clear", 320, 50);
        clearButton.Clicked += (sender, e) => ClearOutput();

        // Create the text view for output
        outputTextView = new TextView
        {
            Editable = false,
            WrapMode = WrapMode.Word
        };

        // Create a ScrolledWindow and add the TextView to it
        var scrolledWindow = new ScrolledWindow();
        scrolledWindow.Add(outputTextView);

        // Add the horizontal box and the scrolled window to the vertical box
        vbox.PackStart(hbox, false, false, 5);
        vbox.PackStart(scrolledWindow, true, true, 5);
        vbox.PackStart(clearButton, false, false, 5);

        // Create the EventBox container which will handle clicks
        EventBox eventBox = new EventBox();
        eventBox.Events |= Gdk.EventMask.ButtonPressMask;

        // Create styled label (looks like a hyperlink)
        Label linkLabel = new Label();
        linkLabel.Markup = "<span foreground=\"aqua\" underline=\"single\">Click here to visit the Wiki!</span>";
        linkLabel.Selectable = false;

        // Handle click to open URL
        eventBox.ButtonPressEvent += (sender, args) =>
        {
            if (args.Event.Button == 1) // Left mouse button only
            {
                try
                {
                    Process.Start("xdg-open", "https://github.com/Heroin-Bob/AudioTools-for-Linux/wiki");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error opening link: {ex.Message}");
                }
            }
        };

        // Add label to event box, event box to vbox
        eventBox.Add(linkLabel);

        vbox.PackStart(eventBox, false, false, 0);

        // Set the policy for the scrollbars
        scrolledWindow.SetPolicy(PolicyType.Automatic, PolicyType.Automatic);

        // Add the vertical box to the window
        window.Add(vbox);
        window.ShowAll();


	string initCommand = @"#!/bin/bash        	
			sampleRate=$(pw-metadata -n settings 0 clock.force-rate | grep -oP '\d+' | tail -n 1)
			if [ $sampleRate -eq 0 ]; then
				sampleRate=$(pw-metadata -n settings 0 clock.rate | grep -oP '\d+' | tail -n 2 | head -n 1)
			fi

			bufferSize=$(pw-metadata -n settings 0 clock.force-quantum | grep -oP '\d+' | tail -n 1)
			if [ $bufferSize -eq 0 ]; then
				bufferSize=$(pw-metadata -n settings 0 clock.rate | grep -oP '\d+' | tail -n 2 | head -n 1)
			fi

			num_plugins=$(echo $($HOME/.local/share/yabridge/yabridgectl sync) | grep -oP '\d+' | tail -n 3 | head -n 1)
			num_new_plugins=$(echo $($HOME/.local/share/yabridge/yabridgectl sync) | grep -oP '\d+' | tail -n 2 | head -n 1)

			playbackDevices=$(pactl list sinks | grep -A1 Name:\ $(pactl get-default-sink) | grep Description | cut -d : -f2 | xargs)
			recordingDevices=$(pactl list sources | grep -A1 Name:\ $(pactl get-default-source) | grep Description | cut -d : -f2 | xargs)

			# Print the results
			clear
			echo Playback Device: $playbackDevices
			echo Recording Device: $recordingDevices
			echo ' '
			echo Number of plugins: $num_plugins
			echo Number of new plugins: $num_new_plugins
			echo Sample Rate: $sampleRate
			echo Buffer Size: $bufferSize";
        RunCommand(initCommand);


        Application.Run();
    }


    private Button CreateButton(string label, int width, int height)
    {
        var button = new Button(label)
        {
            WidthRequest = width,
            HeightRequest = height
        };
        return button;
    }


    private void RunCommand(string command)
    {
        // Clear previous output
        outputTextView.Buffer.Text = "";

        // Set up the process start info
        var processStartInfo = new ProcessStartInfo
        {
            FileName = "/bin/bash",
            Arguments = $"-c \"{command}\"",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        // Start the process
        using (var process = new Process { StartInfo = processStartInfo })
        {
            process.OutputDataReceived += (sender, args) =>
            {
                if (!string.IsNullOrEmpty(args.Data))
                {

                    AppendOutput(args.Data);

                }
            };

            process.ErrorDataReceived += (sender, args) =>
            {
                if (!string.IsNullOrEmpty(args.Data))
                {
                    AppendOutput("Error: " + args.Data);


                }
            };

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();
        }
    }

    private String RunCommandWithReturn(string command)
    {
    	List<string> output = new List<string>();
        var returnValue = "";
        // Set up the process start info
        var processStartInfo = new ProcessStartInfo
        {
            FileName = "/bin/bash",
            Arguments = $"-c \"{command}\"",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        // Start the process
        using (var process = new Process { StartInfo = processStartInfo })
        {
            process.OutputDataReceived += (sender, args) =>
            {
                if (!string.IsNullOrEmpty(args.Data))
                {
                    output.Add(args.Data);
                }
            };

            process.ErrorDataReceived += (sender, args) =>
            {
                if (!string.IsNullOrEmpty(args.Data))
                {
                    output.Add("Error: " + args.Data);

                }
            };

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();
        }
		
        return string.Join("\n",output);
    }

    private void ClearOutput()
    {
        // Clear the text view
        outputTextView.Buffer.Text = "";
    }

    private void AppendOutput(string text)
    {
        // Update the text view in the UI thread
        Application.Invoke(delegate
        {
            if (text.Contains("TERM environment variable not set"))
            {
                outputTextView.Buffer.Text += text.Replace("Error: TERM environment variable not set.", "");
            }
            else
            {
                outputTextView.Buffer.Text += text + "\n";
            }

            outputTextView.ScrollToIter(outputTextView.Buffer.EndIter, 0, false, 0, 0);
        });
    }
    
    static bool IsPath(string line)
    {
        // Check for common path patterns (you can customize this)
        return line.StartsWith("/") || line.Contains("\\") || line.Contains(":");
    }

    public static void Main()
    {
        new AudioTools();
    }
}
