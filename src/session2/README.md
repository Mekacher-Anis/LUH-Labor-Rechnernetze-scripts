# Scripts for second session

## Lab
This session uses the same lab environment as Session.
Please refer to [Session 1](../session1/README.md#lab) for the environment documentation.

In order to be able to simulate rate limiting between `router1` and `router2` and also try different qdiscs; I've added a "transparent" router between router1 and router2 that does the rate limiting, so the it's no longer the job of router1 and router2 to implement rate limiting. This is important because some qdiscs like `pfifo` won't allow u to add another rate limiting class/qdisc as a parent or as a child.

## Scripts
### Test different `qdisc` s or router1
`./test_qdisc.sh` this will:
1. Setup FIFO qdisc on router1
2. Run two concurrent TCP streams between sender/receiver pairs
3. Run one TCP stream between sender1->receiver1 parallel to one UDP stream between sender2->receiver2 with bandwidth 250 Mbit/s
4. Run one TCP stream between sender1->receiver1 parallel to one UDP stream between sender2->receiver2 with bandwidth 750 Mbit/s
5. Run two concurrent UDP stream between sender/receiver pairs
6. Retrieve the logs from the receiver for all tests
7. Repeat steps 1 -> 6 for qdisc SFQ and TBF