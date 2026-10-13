import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("EventFoundModule", (m) => {
  const registry = m.contract("ParticipantRegistry");
  const fund = m.contract("EventFund", [registry]);
  const manager = m.contract("EventManager", [registry, fund]);
  m.call(fund, "setManager", [manager]);
  return {registry, fund, manager};


});