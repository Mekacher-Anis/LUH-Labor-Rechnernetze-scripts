#!/usr/bin/env python3

import matplotlib.pyplot as plt
import pandas as pd
from datetime import datetime

list_of_plot_combinations = [
    # (
    #     "src/session3/output/owd_0/owd.png",
    #     "Time (s)",
    #     "Delay (ms)",
    #     0.7,
    #     [
    #         (
    #             "src/session3/output/owd_0/sender1_receiver1/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "r",
    #             "Jitter",
    #             0
    #         ),
    #         (
    #             "src/session3/output/owd_0/sender1_receiver2/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "g",
    #             "Jitter",
    #             0
    #         ),
    #         (
    #             "src/session3/output/owd_0/sender2_receiver1/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "b",
    #             "Jitter",
    #             0
    #         ),
    #         (
    #             "src/session3/output/owd_0/sender2_receiver2/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "k",
    #             "Jitter",
    #             0
    #         ),
    #     ],
    # ),
    # (
    #     "src/session3/output/owd_1/owd.png",
    #     "Time (s)",
    #     "Delay (ms)",
    #     0.7,
    #     [
    #         (
    #             "src/session3/output/owd_1/sender1_receiver1/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "r",
    #             "Jitter",
    #             0
    #         ),
    #         (
    #             "src/session3/output/owd_1/sender1_receiver2/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "g",
    #             "Jitter",
    #             0
    #         ),
    #         (
    #             "src/session3/output/owd_1/sender2_receiver1/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "b",
    #             "Jitter",
    #             0
    #         ),
    #         (
    #             "src/session3/output/owd_1/sender2_receiver2/combined_stats.csv",
    #             "Time",
    #             "Delay",
    #             "k",
    #             "Jitter",
    #             0
    #         ),
    #     ],
    # ),
    # (
    #     "src/session3/output/test_fifo/plot.png",
    #     "Time (s)",
    #     "Bitrate (bitps)",
    #     1,
    #     [
    #         *[
    #             (
    #                 f"src/session3/output/test_fifo/test_fifo_receiver1_cbr_{(i+1)*10}.csv",
    #                 "Time",
    #                 "Bitrate",
    #                 "r",
    #                 None,
    #                 i * 10,
    #             )
    #             for i in range(10)
    #         ],
    #         *[
    #             (
    #                 f"src/session3/output/test_fifo/test_fifo_sender1_cbr_{(i+1)*10}.csv",
    #                 "Time",
    #                 "Bitrate",
    #                 "g",
    #                 None,
    #                 i * 10,
    #             )
    #             for i in range(10)
    #         ],
    #         *[
    #             (
    #                 f"src/session3/output/test_fifo/test_fifo_receiver2_xt_{(i+1)*10}.csv",
    #                 "Time",
    #                 "Bitrate",
    #                 "b",
    #                 None,
    #                 i * 10,
    #             )
    #             for i in range(10)
    #         ],
    #         *[
    #             (
    #                 f"src/session3/output/test_fifo/test_fifo_sender2_xt_{(i+1)*10}.csv",
    #                 "Time",
    #                 "Bitrate",
    #                 "k",
    #                 None,
    #                 i * 10,
    #             )
    #             for i in range(10)
    #         ],
    #     ],
    # ),
    (
        "src/session3/output/spruce/spruce.png",
        "Cross Traffic Rate (MBit/s)",
        "AvBw (Mbit/s)",
        1.0,
        [
            (
                "src/session3/output/spruce/spruce.csv",
                "XT_Rate",
                "Throughput",
                "r",
                None,
                0,
            ),
        ],
    )
]

for plots in list_of_plot_combinations:
    plt.figure(figsize=(10, 5))
    output_file, x_label, y_label, alpha, subplots = plots
    for subplot in subplots:
        if len(subplot) == 5:
            filepath, x, y, style, x_displacement = subplot
        else:
            filepath, x, y, style, sd, x_displacement = subplot

        df = pd.read_csv(filepath, delimiter=",")
        df.drop(df.tail(1).index, inplace=True)

        if x == "timestamp":
            df[x] = df[x].apply(lambda t: datetime.strptime(str(t), "%Y%m%d%H%M%S"))

        if y == "throughput bits/s":
            df[y] = df[y] / 10**6

        if y == "Bitrate":
            df[y] = df[y] / 1000

        if sd is None:
            plt.plot(df[x] + x_displacement, df[y], color=style)
        else:
            plt.errorbar(df[x], df[y], yerr=df[sd], color=style, alpha=alpha)

    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.savefig(output_file)
