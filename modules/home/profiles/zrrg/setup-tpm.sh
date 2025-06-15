#!/bin/bash
# Setup script for tmux plugin manager

# Create tmux plugins directory
mkdir -p ~/.tmux/plugins

# Clone tmux plugin manager
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins

echo "Tmux plugin manager setup complete!"
echo "You can now use tmux and the plugins will be available." 