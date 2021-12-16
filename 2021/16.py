#!/usr/bin/env python3
from abc import ABC, abstractmethod
from functools import reduce
import operator
from os.path import dirname
import re

class Packet(ABC):
    def __init__(self, version: int, type_id: int, subpackets: list, length: int):
        self.version = version
        self.type_id = type_id
        self.subpackets = subpackets
        self.length = length

    @abstractmethod
    def reduce_values(self, values: list[int]) -> int:
        pass

    def value(self) -> int:
        subpacket_values = [subpacket.value() for subpacket in self.subpackets]
        return self.reduce_values(subpacket_values)

    def version_sum(self) -> int:
        return self.version + sum([subpacket.version_sum() for subpacket in self.subpackets])

class SumPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return sum(values)

class ProductPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return reduce(operator.mul, values, 1)

class MinimumPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return min(values)

class MaximumPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return max(values)

class LiteralPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return -1

    def value(self) -> int:
        return int(''.join([group_string[1:] for group_string in self.subpackets]), 2)

    def version_sum(self) -> int:
        return self.version

class GreaterThanPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return int(values[0] > values[1])

class LessThanPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return int(values[0] < values[1])

class EqualToPacket(Packet):
    def reduce_values(self, values: list[int]) -> int:
        return int(values[0] == values[1])


class PacketParser:
    PACKET_TYPES = [
        SumPacket,
        ProductPacket,
        MinimumPacket,
        MaximumPacket,
        LiteralPacket,
        GreaterThanPacket,
        LessThanPacket,
        EqualToPacket
    ]

    @staticmethod
    def extract_binary(bin_str, start, length) -> int:
        return int(bin_str[start:start + length], 2)

    @classmethod
    def parse(cls, bin_str: str, start: int = 0) -> Packet:
        head = start
        version = cls.extract_binary(bin_str, head, 3)
        type_id = cls.extract_binary(bin_str, head + 3, 3)
        subpackets = []
        head += 6

        if type_id == 4:
            while True:
                subpacket = bin_str[head:head + 5]
                subpackets.append(subpacket)
                head += 5
                if subpacket[0] == '0':
                    break
        else:
            length_type_id = cls.extract_binary(bin_str, head, 1)
            head += 1
            if length_type_id == 0:
                subpacket_length = cls.extract_binary(bin_str, head, 15)
                head += 15
                limit = head + subpacket_length
                while head < limit:
                    subpacket = cls.parse(bin_str, head)
                    subpackets.append(subpacket)
                    head += subpacket.length
            else:
                subpacket_count = cls.extract_binary(bin_str, head, 11)
                head += 11
                for _ in range(subpacket_count):
                    subpacket = cls.parse(bin_str, head)
                    subpackets.append(subpacket)
                    head += subpacket.length
        return cls.PACKET_TYPES[type_id](version, type_id, subpackets, head - start)


f = open(f'{dirname(__file__)}/16.txt', 'r')
hex_str = f.read().rstrip()
bin_str = re.sub(r'.', lambda match: bin(int(match.group(0), 16))[2:].zfill(4), hex_str)

outermost_packet = PacketParser.parse(bin_str, 0)
print(f'Part 1: {outermost_packet.version_sum()}')
print(f'Part 2: {outermost_packet.value()}')
