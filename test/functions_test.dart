// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:test/test.dart";

import "package:collection/collection.dart";

void main() {
  group("mapMap()", () {
    test("with an empty map returns an empty map", () {
      expect(
          mapMap({},
              key: expectAsync((_, __) {}, count: 0),
              value: expectAsync((_, __) {}, count: 0)),
          isEmpty);
    });

    test("with no callbacks, returns a copy of the map", () {
      var map = {"foo": 1, "bar": 2};
      var result = mapMap(map);
      expect(result, equals({"foo": 1, "bar": 2}));

      // The resulting map should be a copy.
      result["foo"] = 3;
      expect(map, equals({"foo": 1, "bar": 2}));
    });

    test("maps the map's keys", () {
      expect(mapMap({"foo": 1, "bar": 2}, key: (key, value) => key[value]),
          equals({"o": 1, "r": 2}));
    });

    test("maps the map's values", () {
      expect(mapMap({"foo": 1, "bar": 2}, value: (key, value) => key[value]),
          equals({"foo": "o", "bar": "r"}));
    });

    test("maps both the map's keys and values", () {
      expect(
          mapMap({"foo": 1, "bar": 2},
              key: (key, value) => "$key$value",
              value: (key, value) => key[value]),
          equals({"foo1": "o", "bar2": "r"}));
    });
  });

  group("mergeMaps()", () {
    test("with empty maps returns an empty map", () {
      expect(mergeMaps({}, {}, value: expectAsync((_, __) {}, count: 0)),
          isEmpty);
    });

    test("returns a map with all values in both input maps", () {
      expect(mergeMaps({"foo": 1, "bar": 2}, {"baz": 3, "qux": 4}),
          equals({"foo": 1, "bar": 2, "baz": 3, "qux": 4}));
    });

    test("the second map's values win by default", () {
      expect(mergeMaps({"foo": 1, "bar": 2}, {"bar": 3, "baz": 4}),
          equals({"foo": 1, "bar": 3, "baz": 4}));
    });

    test("uses the callback to merge values", () {
      expect(mergeMaps({"foo": 1, "bar": 2}, {"bar": 3, "baz": 4},
              value: (value1, value2) => value1 + value2),
          equals({"foo": 1, "bar": 5, "baz": 4}));
    });
  });

  group("groupBy()", () {
    test("returns an empty map for an empty iterable", () {
      expect(groupBy([], expectAsync((_) {}, count: 0)), isEmpty);
    });

    test("groups elements by the function's return value", () {
      expect(
          groupBy(["foo", "bar", "baz", "bop", "qux"], (string) => string[1]),
          equals({"o": ["foo", "bop"], "a": ["bar", "baz"], "u": ["qux"]}));
    });
  });

  group("minBy()", () {
    test("returns null for an empty iterable", () {
      expect(
          minBy([], expectAsync((_) {}, count: 0),
              compare: expectAsync((_, __) {}, count: 0)),
          isNull);
    });

    test("returns the element for which the ordering function returns the "
        "smallest value", () {
      expect(
          minBy(
              [{"foo": 3}, {"foo": 5}, {"foo": 4}, {"foo": 1}, {"foo": 2}],
              (map) => map["foo"]),
          equals({"foo": 1}));
    });

    test("uses a custom comparator if provided", () {
      expect(
          minBy(
              [{"foo": 3}, {"foo": 5}, {"foo": 4}, {"foo": 1}, {"foo": 2}],
              (map) => map,
              compare: (map1, map2) => map1["foo"].compareTo(map2["foo"])),
          equals({"foo": 1}));
    });
  });

  group("maxBy()", () {
    test("returns null for an empty iterable", () {
      expect(
          maxBy([], expectAsync((_) {}, count: 0),
              compare: expectAsync((_, __) {}, count: 0)),
          isNull);
    });

    test("returns the element for which the ordering function returns the "
        "largest value", () {
      expect(
          maxBy(
              [{"foo": 3}, {"foo": 5}, {"foo": 4}, {"foo": 1}, {"foo": 2}],
              (map) => map["foo"]),
          equals({"foo": 5}));
    });

    test("uses a custom comparator if provided", () {
      expect(
          maxBy(
              [{"foo": 3}, {"foo": 5}, {"foo": 4}, {"foo": 1}, {"foo": 2}],
              (map) => map,
              compare: (map1, map2) => map1["foo"].compareTo(map2["foo"])),
          equals({"foo": 5}));
    });
  });

  group("transitiveClosure()", () {
    test("returns an empty map for an empty graph", () {
      expect(transitiveClosure({}), isEmpty);
    });

    test("returns the input when there are no transitive connections", () {
      expect(transitiveClosure({
        "foo": ["bar"],
        "bar": [],
        "bang": ["qux", "zap"],
        "qux": [],
        "zap": []
      }), equals({
        "foo": ["bar"],
        "bar": [],
        "bang": ["qux", "zap"],
        "qux": [],
        "zap": []
      }));
    });

    test("flattens transitive connections", () {
      expect(transitiveClosure({
        "qux": [],
        "bar": ["baz"],
        "baz": ["qux"],
        "foo": ["bar"]
      }), equals({
        "foo": ["bar", "baz", "qux"],
        "bar": ["baz", "qux"],
        "baz": ["qux"],
        "qux": []
      }));
    });

    test("handles loops", () {
      expect(transitiveClosure({
        "foo": ["bar"],
        "bar": ["baz"],
        "baz": ["foo"]
      }), equals({
        "foo": ["bar", "baz", "foo"],
        "bar": ["baz", "foo", "bar"],
        "baz": ["foo", "bar", "baz"]
      }));
    });
  });

  group("stronglyConnectedComponents()", () {
    test("returns an empty list for an empty graph", () {
      expect(stronglyConnectedComponents({}), isEmpty);
    });

    test("returns one set for a singleton graph", () {
      expect(stronglyConnectedComponents({"a": []}),
          equals([new Set.from(["a"])]));
    });

    test("returns two sets for a two-element tree", () {
      expect(stronglyConnectedComponents({"a": ["b"], "b": []}),
          equals([new Set.from(["a"]), new Set.from(["b"])]));
    });

    test("returns one set for a two-element loop", () {
      expect(stronglyConnectedComponents({"a": ["b"], "b": ["a"]}),
          equals([new Set.from(["a", "b"])]));
    });

    test("returns individual vertices for a tree", () {
      expect(stronglyConnectedComponents({
        "foo": ["bar"],
        "bar": ["baz", "bang"],
        "baz": ["qux"],
        "bang": ["zap"],
        "qux": [],
        "zap": []
      }), equals([
        // This is expected to return *a* topological ordering, but this isn't
        // the only valid one. If the function implementation changes in the
        // future, this test may need to be updated.
        new Set.from(["foo"]),
        new Set.from(["bar"]),
        new Set.from(["bang"]),
        new Set.from(["zap"]),
        new Set.from(["baz"]),
        new Set.from(["qux"])
      ]));
    });

    test("returns a single set for a fully cyclic graph", () {
      expect(stronglyConnectedComponents({
        "foo": ["bar"],
        "bar": ["baz"],
        "baz": ["bang"],
        "bang": ["foo"]
      }), equals([new Set.from(["foo", "bar", "baz", "bang"])]));
    });

    test("returns separate sets for each strongly connected component", () {
      // https://en.wikipedia.org/wiki/Strongly_connected_component#/media/File:Scc.png
      expect(stronglyConnectedComponents({
        "a": ["b"],
        "b": ["c", "e", "f"],
        "c": ["d", "g"],
        "d": ["c", "h"],
        "e": ["a", "f"],
        "f": ["g"],
        "g": ["f"],
        "h": ["g", "d"]
      }), equals([
        // This is expected to return *a* topological ordering, but this isn't
        // the only valid one. If the function implementation changes in the
        // future, this test may need to be updated.
        new Set.from(["a", "b", "e"]),
        new Set.from(["c", "d", "h"]),
        new Set.from(["f", "g"]),
      ]));
    });

    test("always returns components in topological order", () {
      expect(stronglyConnectedComponents({
        "bar": ["baz", "bang"],
        "zap": [],
        "baz": ["qux"],
        "qux": [],
        "foo": ["bar"],
        "bang": ["zap"]
      }), equals([
        // This is expected to return *a* topological ordering, but this isn't
        // the only valid one. If the function implementation changes in the
        // future, this test may need to be updated.
        new Set.from(["foo"]),
        new Set.from(["bar"]),
        new Set.from(["bang"]),
        new Set.from(["zap"]),
        new Set.from(["baz"]),
        new Set.from(["qux"])
      ]));
    });
  });
}
