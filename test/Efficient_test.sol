pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Efficient.sol";

contract BallotTest {

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
        Assert.equal(contractInstance.getLength(), 3, "proposal at index 0 should be the winning proposal");
    }

    function t11 () public {
        string[] memory data1 = new string[](3);
        data1[0] = "a";
        data1[1] = "a";
        data1[2] = "a";
        contractInstance.addAll(data1);
        Assert.equal(contractInstance.getLength(), 3, "proposal at index 0 should be the winning proposal");
    }

    function t2() public {
        // Test Case 2
        string[] memory data2 = new string[](4);
        data2[0] = "a";
        data2[1] = "a";
        data2[2] = "b";
        data2[2] = "b";
        contractInstance.addAll(data2);
        Assert.equal(contractInstance.getLength(), 4, "proposal at index 0 should be the winning proposal");
    }

    function t3() public {
        string[] memory data3 = new string[](5);
        data3[0] = "a";
        data3[1] = "b";
        data3[2] = "a";
        data3[2] = "c";
        data3[2] = "b";
        contractInstance.addAll(data3);
        Assert.equal(contractInstance.getLength(), 5, "proposal at index 0 should be the winning proposal");
    }

    function t4() public {
        // Test Case 4 (Adding an empty array)
        string[] memory data4 = new string[](0);
        contractInstance.addAll(data4);
        Assert.equal(contractInstance.getLength(), 0, "proposal at index 0 should be the winning proposal");
    }
}