FROM nixos/nix:latest

# Enable flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /app

# Install direnv
RUN nix-env -iA nixpkgs.direnv

# Copy project files
COPY . .

# Set up the shell
CMD ["nix", "develop", ".#backend"]