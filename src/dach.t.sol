pragma solidity ^0.4.23;

import "ds-test/test.sol";

import "./dach.sol";

contract Lad {
}

contract DachTest is DSTest {
    Dach dach;
    Mover mover;
    Lad ali;
    Lad bob;
    address cal = 0x29c76e6ad8f28bb1004902578fb108c507be341b;
    address del = 0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479;
    uint amount = 2;
    uint fee = 1;
    uint nonce = 0;
    //output from generateSigs.js; a signed, typed message from cal of a cheque
    //specifying a 2 dai transfer to del with a 1 dai fee to msg.sender
    string sig = '0x1c539435b3cc80a7354add9b1198092632f900934b336f8d0a75e40cc1ddf7da0b8918b6953d6a88954a434303bf0a41accd811a1a5ca70ca6444a6c8c8ec0151c';
    //the string above is not used anywhere, we decompose it into the following params:
    uint8 v = 28;
    bytes32 r = 0x1c539435b3cc80a7354add9b1198092632f900934b336f8d0a75e40cc1ddf7da;
    bytes32 s = 0x0b8918b6953d6a88954a434303bf0a41accd811a1a5ca70ca6444a6c8c8ec015;

    function setUp() public {
      dach = new Dach();
      mover = Mover(dach.mover());
      ali = new Lad();
      bob = new Lad();
      mover.mint(ali, 100);
      mover.mint(cal,80);
      assertTrue(mover.balanceOf(ali) == 100);      
      assertEq(mover.balanceOf(cal),80);
    }

    function testFail_basic_sanity() public {
      assertTrue(false);
    }

    function test_basic_sanity() public {
      assertTrue(true);
      assertTrue(mover.balanceOf(cal) == 80);
    }

    function test_oneMove() public {
      assertTrue(mover.balanceOf(ali) == 100);      
      assertEq(mover.balanceOf(bob),0);
      mover.move(ali, bob, 10);
      assertTrue(mover.balanceOf(bob) == 10);
      assertTrue(mover.balanceOf(ali) == 90);
    }

    function test_domain_sep() public {
      assertEq(dach.DOMAIN_SEPARATOR(), 0xb2240f1d5346f6d79d915a641f2e3ff57024d09b05d1ee76fda676119b4de90b);
    }

    function test_cheque_typehash() public {
      assertEq(dach.CHEQUE_TYPEHASH(), 0x3f2386d9e00bfe3dbbdeb444816f2d701398001e2c2b9051190e2198f4f46caa);
    }

    function test_clear() public {
      assertEq(mover.balanceOf(cal),80);
      assertEq(mover.balanceOf(del),0);
      assertEq(mover.balanceOf(this),0);
      dach.clear(cal, del, 2, 1, 0, v, r, s);
      assertEq(mover.balanceOf(cal),77);
      assertEq(mover.balanceOf(del),2);
      assertEq(mover.balanceOf(this),1);
    }

    function test_replay_protection() public {
      //Resubmitting the same cheque results in a throw
      dach.clear(cal, del, 2, 1, 0, v, r, s);
      assertEq(mover.balanceOf(cal),77);
      assertEq(mover.balanceOf(del),2);
      assertEq(mover.balanceOf(this),1);
    }
}
