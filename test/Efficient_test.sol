pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/Efficient.sol";

contract EfficientContractTest {

    EfficientContract contractInstance;
    function beforeEach () public {
        contractInstance = new EfficientContract();
    }

    function t1 () public {
        string[] memory data1 = new string[](3);
        data1[0] = "a";
        data1[1] = "b";
        data1[2] = "c";
        contractInstance.addAll(data1);
        Assert.equal(contractInstance.getLength(), 3, "length should be 3");
        Assert.equal(contractInstance.count("a"), 1, "a appears 1");
        Assert.equal(contractInstance.count("b"), 1, "b appears 1");
        Assert.equal(contractInstance.count("c"), 1, "c appears 1");
    }

    function t11 () public {
        string[] memory data1 = new string[](3);
        data1[0] = "a";
        data1[1] = "a";
        data1[2] = "a";
        contractInstance.addAll(data1);
        Assert.equal(contractInstance.getLength(), 3, "length should be 3");
        Assert.equal(contractInstance.count("a"), 3, "a appears 3");
    }

    function t2() public {
        // Test Case 2
        string[] memory data2 = new string[](4);
        data2[0] = "a";
        data2[1] = "a";
        data2[2] = "b";
        data2[3] = "b";
        contractInstance.addAll(data2);
        Assert.equal(contractInstance.getLength(), 4, "length should be 4");
        Assert.equal(contractInstance.count("a"), 2, "a appears 2");
        Assert.equal(contractInstance.count("b"), 2, "b appears 2");
    }

    function t3() public {
        string[] memory data3 = new string[](5);
        data3[0] = "a";
        data3[1] = "b";
        data3[2] = "a";
        data3[3] = "c";
        data3[4] = "b";
        contractInstance.addAll(data3);
        Assert.equal(contractInstance.getLength(), 5, "length should be 5");
        Assert.equal(contractInstance.count("a"), 2, "a appears 2");
        Assert.equal(contractInstance.count("b"), 2, "b appears 2");
        Assert.equal(contractInstance.count("c"), 1, "c appears 1");
    }

    function t33() public {
        string[] memory data3 = new string[](5);
        data3[0] = "a";
        data3[1] = "b";
        data3[2] = "c";
        data3[3] = "d";
        data3[4] = "d";
        contractInstance.addAll(data3);
        Assert.equal(contractInstance.getLength(), 5, "length should be 5");
        Assert.equal(contractInstance.count("a"), 1, "a appears 1");
        Assert.equal(contractInstance.count("b"), 1, "b appears 1");
        Assert.equal(contractInstance.count("c"), 1, "c appears 1");
        Assert.equal(contractInstance.count("d"), 2, "d appears 2");
    }

    function t333() public {
        string[] memory data3 = new string[](5);
        data3[0] = "d";
        data3[1] = "a";
        data3[2] = "b";
        data3[3] = "c";
        data3[4] = "d";
        contractInstance.addAll(data3);
        Assert.equal(contractInstance.getLength(), 5, "length should be 5");
        Assert.equal(contractInstance.count("a"), 1, "a appears 1");
        Assert.equal(contractInstance.count("b"), 1, "b appears 1");
        Assert.equal(contractInstance.count("c"), 1, "c appears 1");
        Assert.equal(contractInstance.count("d"), 2, "d appears 2");
    }

    function t4() public {
        string[] memory data4 = new string[](0);
        contractInstance.addAll(data4);
        Assert.equal(contractInstance.getLength(), 0, "length should be 0");
        Assert.equal(contractInstance.count("a"), 0, "a appears 0");
    }
}