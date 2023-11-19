import matplotlib.pyplot as plt
import pandas as pd
from datetime import datetime

list_of_plot_combinations = [
    (
        "./output/fifo/two_concurrent_tcp_streams.png",
        [
            (
                "./output/fifo/two_concurrent_tcp_streams_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/fifo/two_concurrent_tcp_streams_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/fifo/one_tcp_one_udp_250M.png",
        [
            (
                "./output/fifo/one_tcp_one_udp_250M_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/fifo/one_tcp_one_udp_250M_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/fifo/one_tcp_one_udp_750M.png",
        [
            (
                "./output/fifo/one_tcp_one_udp_750M_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/fifo/one_tcp_one_udp_750M_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/fifo/two_udp_flows.png",
        [
            (
                "./output/fifo/two_udp_flows_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/fifo/two_udp_flows_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/sfq/two_concurrent_tcp_streams.png",
        [
            (
                "./output/sfq/two_concurrent_tcp_streams_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/sfq/two_concurrent_tcp_streams_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/sfq/one_tcp_one_udp_250M.png",
        [
            (
                "./output/sfq/one_tcp_one_udp_250M_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/sfq/one_tcp_one_udp_250M_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/sfq/one_tcp_one_udp_750M.png",
        [
            (
                "./output/sfq/one_tcp_one_udp_750M_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/sfq/one_tcp_one_udp_750M_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/sfq/two_udp_flows.png",
        [
            (
                "./output/sfq/two_udp_flows_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/sfq/two_udp_flows_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/tbf/two_concurrent_tcp_streams.png",
        [
            (
                "./output/tbf/two_concurrent_tcp_streams_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/tbf/two_concurrent_tcp_streams_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/tbf/one_tcp_one_udp_250M.png",
        [
            (
                "./output/tbf/one_tcp_one_udp_250M_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/tbf/one_tcp_one_udp_250M_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/tbf/one_tcp_one_udp_750M.png",
        [
            (
                "./output/tbf/one_tcp_one_udp_750M_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/tbf/one_tcp_one_udp_750M_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
    (
        "./output/tbf/two_udp_flows.png",
        [
            (
                "./output/tbf/two_udp_flows_receiver1.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/tbf/two_udp_flows_receiver2.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
]

list_of_plot_combinations = [
    (
        "./output/exp1/timeline.png",
        [
            (
                "./output/exp1/tc_configuration_experiment1_0s.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/exp1/tc_configuration_experiment1_30s.csv",
                "timestamp",
                "throughput bits/s",
                "r",
            ),
            (
                "./output/exp1/tc_configuration_experiment1_10s.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
            (
                "./output/exp1/tc_configuration_experiment1_50s.csv",
                "timestamp",
                "throughput bits/s",
                "b",
            ),
        ],
    ),
]


for plots in list_of_plot_combinations:
    plt.figure()
    output_file, subplots = plots
    for subplot in subplots:
        filepath, x, y, style = subplot
        df = pd.read_csv(filepath, delimiter=",")
        df.drop(df.tail(1).index, inplace=True)

        if x == "timestamp":
            df[x] = df[x].apply(lambda t: datetime.strptime(str(t), "%Y%m%d%H%M%S"))
        
        if y == "throughput bits/s":
            df[y] = df[y] / 10**6

        # Durchsatzverlauf plotten
        plt.plot(df[x], df[y], color=style)

    plt.xlabel("Time (s)")
    plt.ylabel("Throughput (Mbps)")
    plt.savefig(output_file)
