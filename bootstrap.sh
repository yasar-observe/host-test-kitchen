#!/bin/bash
# Default values
OBSERVE_HOST=""
OBSERVE_TOKEN=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --observe_host)
      OBSERVE_HOST="$2"
      shift 2
      ;;
    --observe_token)
      OBSERVE_TOKEN="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1" >&2
      exit 1
      ;;
  esac
done

# Check if --host and --token are provided
if [ -z "$OBSERVE_HOST" ] || [ -z "$OBSERVE_TOKEN" ]; then
  echo "Usage: $0 --observe_host OBSERVE_HOST --observe_token OBSERVE_TOKEN"
  exit 1
fi

# Install Go
sudo curl -OL https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

sudo yum install git -y

if [ -d "observe_tool" ]; then
  git clone https://github.com/observeinc/observe observe-tool
  cd observe-tool
  go install
fi

bash <(curl -sSl https://raw.githubusercontent.com/yasar-observe/host-configuration-scripts/yasar/init/fluent-bit/linux/observe_fluent_install.sh) --observe_host $OBSERVE_HOST --observe_token $OBSERVE_TOKEN
bash <(curl -sSl https://raw.githubusercontent.com/yasar-observe/host-configuration-scripts/yasar/init/telegraf/linux/observe_telegraf_install.sh) --observe_host $OBSERVE_HOST --observe_token $OBSERVE_TOKEN

/root/go/bin/observe --customerid "105898258671" --site "observe-staging.com" login "yasar@observeinc.com" --read-password <<< password

if /root/go/bin/observe query -q 'filter path = "/fluentbit/metrics" | limit 1' -i 'Default.Host' | sed -n '3q;d'; then
    echo "fluentbit_metrics: passed" >> "/tmp/kitchen/tests/results.txt"
fi