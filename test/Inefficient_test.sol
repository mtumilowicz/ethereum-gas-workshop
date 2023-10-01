pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/Inefficient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract EfficientContractTest {

    InefficientContract contractInstance;
    function beforeEach () public {
        contractInstance = new InefficientContract();
    }

    function differentValuesTest() public {
        // given
        string[] memory data1 = new string[](3);
        data1[0] = "a";
        data1[1] = "b";
        data1[2] = "c";

        // when
        contractInstance.addAll(data1);

        // then
        lengthCheck(3);
        countCheck("a", 1);
        countCheck("b", 1);
        countCheck("c", 1);
    }

    function sameValuesTest() public {
        // given
        string[] memory data1 = new string[](3);
        data1[0] = "a";
        data1[1] = "a";
        data1[2] = "a";

        // when
        contractInstance.addAll(data1);

        // then
        lengthCheck(3);
        countCheck("a", 3);
    }

    function pairwiseSameValuesTest() public {
        // given
        string[] memory data2 = new string[](4);
        data2[0] = "a";
        data2[1] = "a";
        data2[2] = "b";
        data2[3] = "b";

        // when
        contractInstance.addAll(data2);

        // then
        lengthCheck(4);
        countCheck("a", 2);
        countCheck("b", 2);
    }

    function pairwiseSameValuesInterleavedTest() public {
        // given
        string[] memory data2 = new string[](4);
        data2[0] = "a";
        data2[1] = "b";
        data2[2] = "a";
        data2[3] = "b";

        // when
        contractInstance.addAll(data2);

        // then
        lengthCheck(4);
        countCheck("a", 2);
        countCheck("b", 2);
    }

    function pairwiseSameValuesAndOneDistinctInterleavedTest() public {
        // given
        string[] memory data3 = new string[](5);
        data3[0] = "a";
        data3[1] = "b";
        data3[2] = "a";
        data3[3] = "c";
        data3[4] = "b";

        // when
        contractInstance.addAll(data3);

        // then
        lengthCheck(5);
        countCheck("a", 2);
        countCheck("b", 2);
        countCheck("c", 1);
    }

    function threeDistinctAndOnePairTest() public {
        // given
        string[] memory data3 = new string[](5);
        data3[0] = "a";
        data3[1] = "b";
        data3[2] = "c";
        data3[3] = "d";
        data3[4] = "d";

        // when
        contractInstance.addAll(data3);

        // then
        lengthCheck(5);
        countCheck("a", 1);
        countCheck("b", 1);
        countCheck("c", 1);
        countCheck("d", 2);
    }

    function threeDistinctAndOnePairInterleavedTest() public {
        // given
        string[] memory data3 = new string[](5);
        data3[0] = "d";
        data3[1] = "a";
        data3[2] = "b";
        data3[3] = "c";
        data3[4] = "d";

        // when
        contractInstance.addAll(data3);

        // then
        lengthCheck(5);
        countCheck("a", 1);
        countCheck("b", 1);
        countCheck("c", 1);
        countCheck("d", 2);
    }

    function emptyDataTest() public {
        // given
        string[] memory data4 = new string[](0);

        // when
        contractInstance.addAll(data4);

        // then
        lengthCheck(0);
        countCheck("a", 0);
    }

    function lengthCheck(uint expectedValue) private {
        Assert.equal(contractInstance.getLength(), expectedValue, string.concat("length should be ", Strings.toString(expectedValue)));
    }

    function countCheck(string memory searchedString, uint expectedCount) private {
        Assert.equal(contractInstance.count(searchedString), expectedCount,  string.concat(searchedString, " should appear ", Strings.toString(expectedCount)));
    }
}